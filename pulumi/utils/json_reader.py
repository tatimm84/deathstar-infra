# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
JSON configuration file reader utility.
Replaces Terraform modules/utils/reader module.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import sys
from typing import Any

from jinja2 import Environment


def slugify(name: str, max_len: int = 80) -> str:
    """
    Sanitiza strings para uso em nomes de recursos Pulumi.
    Substitui caracteres não [a-zA-Z0-9_-] por '_', e limita tamanho.
    """
    return re.sub(r"[^a-zA-Z0-9_-]+", "_", name)[:max_len]


def _fix_jinja_var_syntax(content: str) -> str:
    """
    Pre-process content to fix "${var}" syntax inside %{ ... } blocks.
    Converts: %{ if "${var}" == "val" } -> %{ if var == "val" }
    This allows users to use their familiar syntax even though Jinja doesn't support it
    natively.
    """

    def _fixer(match):
        block_content = match.group(0)
        # Verify if it's a block that needs fixing (heuristic)
        # Replace "${var}" with var inside the block
        return re.sub(r'"\$\{(\w+)\}"', r"\1", block_content)

    # Pattern: %{ ... } handling nested ${...} to avoid stopping at the first }
    # Matches: %{ ( ${...} OR non-} )* }
    pattern = re.compile(r"%\{(?:(?:\$\{.*?\})|[^}])*\}", re.DOTALL)
    return pattern.sub(_fixer, content)


def render_content(content: str, template_vars: dict[str, str]) -> str:
    """
    Render string content using Jinja2 with custom delimiters.

    Args:
        content: Raw content string
        template_vars: Variables for substitution

    Returns:
        Rendered string
    """
    env = Environment(
        block_start_string="%{",
        block_end_string="}",
        variable_start_string="${",
        variable_end_string="}",
        comment_start_string="<!--",
        comment_end_string="-->",
        trim_blocks=True,  # opcional: melhora formatação
        lstrip_blocks=True,  # opcional: remove espaços no início dos blocos
    )
    # Pre-process content to handle "${var}" syntax in blocks
    content_fixed = _fix_jinja_var_syntax(content)

    template = env.from_string(content_fixed)
    return template.render(**template_vars)


def render_json_values(data: Any, template_vars: dict[str, str]) -> Any:
    """
    Recursively render template variables in JSON structures.
    Only renders string values, preserving data types for lists, dicts, etc.

    Args:
        data: JSON data structure (dict, list, str, etc.)
        template_vars: Variables for substitution

    Returns:
        Processed data with template variables rendered in string values
    """
    if isinstance(data, dict):
        return {
            key: render_json_values(value, template_vars) for key, value in data.items()
        }
    elif isinstance(data, list):
        return [render_json_values(item, template_vars) for item in data]
    elif isinstance(data, str):
        # Only render template variables in string values
        return render_content(data, template_vars)
    else:
        # Return other types (int, float, bool, None) as-is
        return data


def path_from_anchor(file_path: Path, anchor: str) -> str:
    """
    Retorna o caminho do arquivo iniciando no segmento 'anchor'.
    Ex.: se anchor='artifact_registry', retorna 'artifact_registry/.../arquivo.json'.
    Se o anchor não for encontrado, retorna somente o nome do arquivo (fallback).
    """
    parts = list(file_path.parts)
    try:
        idx = parts.index(anchor)
        return "/".join(parts[idx:])
    except ValueError:
        return file_path.name


def classify_by_path(source_path: str, search_dir: str) -> str | None:
    """
    Classifica um arquivo pelo seu caminho em relação a um diretório 'search_dir'.

    Retorna:
        str: "root" (arquivo na raiz de search_dir)
            ou "subdir" (arquivo dentro de search_dir/<alguma_coisa>/)
    """
    parts = list(Path(source_path).parts)
    # Encontrar o índice do diretório 'search_dir'
    try:
        idx = parts.index(search_dir)
    except ValueError:
        return None

    after = parts[idx + 1 :]
    if not after:
        return None
    return "root" if len(after) == 1 else "subdir"


def calculate_directory_hash(directory: str) -> str:
    """
    Calculate SHA1 hash of all files in a directory.
    Equivalent to Terraform's sha1(join("", [for f in fileset(...)])).

    Args:
        directory: Directory path

    Returns:
        SHA1 hash string
    """
    dir_path = Path(directory)
    if not dir_path.exists():
        return ""

    hash_parts = []
    for file_path in sorted(dir_path.rglob("*")):
        if file_path.is_file():
            with open(file_path, "rb") as f:
                file_hash = hashlib.sha1(f.read()).hexdigest()
                hash_parts.append(file_hash)

    combined = "".join(hash_parts)
    return hashlib.sha1(combined.encode()).hexdigest()


def read_json_files(
    source_path: str,
    files_regex: str = "**/*.json",
    template_vars: dict[str, str] | None = None,
) -> list[dict[str, Any]]:
    """
    Read and parse JSON configuration files with template variable substitution.
    """
    if template_vars is None:
        template_vars = {}

    parsed_data: list[dict[str, Any]] = []
    source_dir = Path(source_path)

    if not source_dir.exists():
        return parsed_data

    pattern = _get_glob_pattern(files_regex)
    anchor = Path(source_path.rstrip("/\\")).name

    for file_path in source_dir.glob(pattern):
        if (
            not file_path.is_file()
            or file_path.suffix != ".json"
            or file_path.name.startswith(".")
        ):
            continue

        with open(file_path, encoding="utf-8") as f:
            content_raw = f.read()

        content_parsed = _parse_and_render_json(file_path, content_raw, template_vars)

        parsed_data.append(
            {
                "source": path_from_anchor(file_path, anchor),
                "file_name": file_path.stem,
                "file_name_extension": file_path.name,
                "path_type": classify_by_path(str(file_path), anchor),
                "content": content_parsed if content_parsed is not None else {},
                "content_raw": content_raw,
            }
        )

    return parsed_data


def _get_glob_pattern(files_regex: str) -> str:
    """Helper to resolve glob pattern for JSON files."""
    if files_regex == "**":
        return "**/*.json"
    if files_regex == "*":
        return "*.json"
    return files_regex


def _parse_and_render_json(
    file_path: Path, content_raw: str, template_vars: dict[str, str]
) -> Any:
    """Helper to parse and render JSON content with fallbacks."""
    already_rendered = False
    try:
        content_parsed = json.loads(content_raw)
        sys.stderr.write(f"INFO: Processing file: {file_path}\n")
    except json.JSONDecodeError:
        # Fallback: render template first, then parse
        try:
            rendered_raw = render_content(content_raw, template_vars)
            content_parsed = json.loads(rendered_raw)
            already_rendered = True
            sys.stderr.write(f"INFO: Processing file (template-first): {file_path}\n")
        except Exception as e:
            sys.stderr.write(f"ERROR: Failed to parse JSON for {file_path}: {e}\n")
            return None

    if content_parsed is not None and not already_rendered:
        try:
            content_parsed = render_json_values(content_parsed, template_vars)
        except Exception as e:
            sys.stderr.write(f"ERROR: Failed to render template for {file_path}: {e}\n")
            # Fall back to original parsed content
            try:
                content_parsed = json.loads(content_raw)
            except json.JSONDecodeError:
                content_parsed = None

    return content_parsed


def _resolve_glob_pattern(files_regex: str) -> str:
    """Resolve o padrão de glob a partir do parâmetro do usuário."""
    if files_regex == "[^.]**/**":
        # Match all files in subdirectories, excluding hidden files
        return "**/*"
    return files_regex


def read_non_json_files(
    source_path: str,
    files_regex: str = "**/*",
    template_vars: dict[str, str] | None = None,
) -> list[dict[str, Any]]:
    """
    Read non-JSON files (for object uploads, etc.).
    """
    template_vars = template_vars or {}
    pattern = _resolve_glob_pattern(files_regex)
    parsed_data: list[dict[str, Any]] = []
    source_dir = Path(source_path)

    if not source_dir.exists():
        return parsed_data

    anchor = Path(source_path.rstrip("/\\")).name

    for file_path in source_dir.glob(pattern):
        is_json = file_path.suffix == ".json"
        if not file_path.is_file() or is_json or file_path.name.startswith("."):
            continue

        content_raw = _read_and_render_non_json(file_path, template_vars)

        parsed_data.append(
            {
                "source": path_from_anchor(file_path, anchor),
                "file_name": file_path.stem,
                "file_name_extension": file_path.name,
                "path_type": classify_by_path(str(file_path), anchor),
                "content": None,
                "content_raw": content_raw,
            }
        )

    return parsed_data


def _read_and_render_non_json(
    file_path: Path, template_vars: dict[str, str]
) -> str | None:
    """Helper to read and optionally render non-JSON files."""
    try:
        sys.stderr.write(f"INFO: Processing file: {file_path}\n")
        with open(file_path, "rb") as fb:
            raw_bytes = fb.read()

        is_binary = b"\x00" in raw_bytes
        text = None
        if not is_binary:
            try:
                text = raw_bytes.decode("utf-8-sig", "strict")
            except UnicodeDecodeError:
                is_binary = True

        if is_binary:
            return None

        # Render template em texto
        try:
            return render_content(text, template_vars) if text is not None else None
        except Exception as e:
            msg = f"WARNING: Failed to render template for {file_path}. Error: {e}\n"
            sys.stderr.write(msg)
            return text
    except (UnicodeDecodeError, PermissionError, OSError) as e:
        sys.stderr.write(f"ERROR: Failed to read content for {file_path}: {e}\n")
        return None
