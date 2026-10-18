# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

from __future__ import annotations

import re
import sys
from typing import Any, Union, cast, get_args, get_origin


# ------------------ Utils -----------------
def is_empty(value: Any) -> bool:
    """Verify empty values."""
    if value is None:
        return True
    if isinstance(value, str) and value.strip() == "":
        return True
    if isinstance(value, (list, dict, set, tuple)) and len(value) == 0:
        return True
    return False


def get_value_by_path(
    data: dict[str, Any], path: str, sep: str = "_"
) -> tuple[Any, bool]:
    """Obtém o valor seguindo um caminho com separador (ex.: 'end_rua')."""

    # 1) TRY LITERAL KEY FIRST (ex.: 'image_path' as a single key)
    if isinstance(data, dict) and path in data:
        return data[path], True

    # 2) IF NOT FOUND, TRY WITH SEPARATOR (ex.: 'image_path' as 'image_path')
    keys = path.split(sep) if (sep is not None and sep != "") else [path]

    def walk(cur: Any, i: int) -> tuple[Any, bool]:
        # Chegou ao fim do caminho: devolver o valor atual
        if i == len(keys):
            return cur, True

        k = keys[i]

        # Caso dicionário: segue normalmente
        if isinstance(cur, dict):
            if k in cur:
                return walk(cur[k], i + 1)
            else:
                return None, False

        # NOVO: caso lista: aplica recursão em TODOS os itens, SEM consumir a chave k
        if isinstance(cur, list):
            collected = []
            for elem in cur:
                val, ok = walk(elem, i)  # ainda procurando k dentro de cada elem
                if not ok:
                    return None, False  # se faltar em qualquer item, considerar ausente
                collected.append(val)
            return collected, True

        # Qualquer outro tipo não suporta navegação adicional
        return None, False

    return walk(data, 0)


def set_value_by_path(
    data: dict[str, Any], path: str, value: Any, sep: str = "_"
) -> None:
    """Define um valor seguindo 'path' com separador,
    criando dicionários conforme necessário."""
    keys = path.split(sep)
    d = data
    for k in keys[:-1]:
        if k not in d or not isinstance(d[k], dict):
            d[k] = {}
        d = d[k]
    d[keys[-1]] = value


# ------------------ Type Checking ------------------
def check_type(value: Any, expected_type: Any) -> bool:
    """
    Verify type compatibility of 'value' with 'expected_type'.
    Supports: primary Python types (int, str, bool, float, tuple), Optional, Union
    """
    # Simple union as tuple (ex.: (int, str)) or generic union (ex.: (dict[str, Any], list[dict[str, Any]]))
    if isinstance(expected_type, tuple):
        if all(isinstance(x, type) for x in expected_type):
            return isinstance(value, expected_type)
        # Treat as Union-like: check if value matches any element (handles _GenericAlias elements)
        return any(check_type(value, arg) for arg in expected_type)

    origin = get_origin(expected_type)
    args = get_args(expected_type)

    # Simple type (int, str, bool, float, dict, list, etc.)
    if origin is None:
        if expected_type is Any:
            return True
        if isinstance(expected_type, type):
            return isinstance(value, expected_type)
        # Unknown type (ex.: ForwardRef or something not supported)
        return False

    # Union / Optional
    if origin is Union:
        return any(check_type(value, arg) for arg in args)

    return _check_container_types(value, origin, args)


def _check_container_types(value: Any, origin: Any, args: tuple[Any, ...]) -> bool:
    """Helper for check_type to handle containers (list, dict, tuple, set)."""
    if origin in (list, list):
        return _check_list_type(value, args)
    if origin in (dict, dict):
        return _check_dict_type(value, args)
    if origin in (tuple, tuple):
        return _check_tuple_type(value, args)
    if origin in (set, set):
        return _check_set_type(value, args)
    try:
        return isinstance(value, origin)
    except Exception:
        return False


def _check_list_type(value: Any, args: tuple[Any, ...]) -> bool:
    """Check List[T]."""
    if not isinstance(value, list):
        return False
    return not args or all(check_type(item, args[0]) for item in value)


def _check_dict_type(value: Any, args: tuple[Any, ...]) -> bool:
    """Check Dict[K, V]."""
    if not isinstance(value, dict):
        return False
    if len(args) < 2:  # noqa: PLR2004
        return True
    return all(
        check_type(k, args[0]) and check_type(v, args[1]) for k, v in value.items()
    )


def _check_tuple_type(value: Any, args: tuple[Any, ...]) -> bool:
    """Check Tuple[...] or Tuple[T, ...]."""
    if not isinstance(value, tuple):
        return False
    if not args:
        return True
    if len(args) == 2 and args[1] is Ellipsis:  # noqa: PLR2004
        return all(check_type(item, args[0]) for item in value)
    if len(value) != len(args):
        return False
    return all(check_type(item, arg) for item, arg in zip(value, args, strict=True))


def _check_set_type(value: Any, args: tuple[Any, ...]) -> bool:
    """Check Set[T]."""
    if not isinstance(value, set):
        return False
    return not args or all(check_type(item, args[0]) for item in value)


# ------------------ Schema Normalization ------------------
def _html_unescape(s: str) -> str:
    return s.replace("&gt;", ">").replace("&lt;", "<").replace("&amp;", "&")


def parse_type_hint(type_str: str) -> Any:
    """
    Convert strings like 'list(str)' and 'dict(str, str)' to valid type hints.
    """
    type_str = type_str.strip().lower()
    mapping = {
        "str": str,
        "int": int,
        "float": float,
        "bool": bool,
        "any": Any,
        "none": type(None),
        "null": type(None),
        "list": list,
        "dict": dict,
        "tuple": tuple,
        "set": set,
    }

    if type_str in mapping:
        return mapping[type_str]

    if type_str.startswith("list(") and type_str.endswith(")"):
        return list[Any]  # Dynamic type hint parsing

    if type_str.startswith("set(") and type_str.endswith(")"):
        return set[Any]

    if type_str.startswith("dict(") and type_str.endswith(")"):
        return _parse_dict_hint(type_str)

    if type_str.startswith("tuple(") and type_str.endswith(")"):
        return _parse_tuple_hint(type_str)

    return Any


def _parse_dict_hint(type_str: str) -> Any:
    """Helper to parse dict(K, V)."""
    parts = type_str[5:-1].split(",", 1)
    if len(parts) == 2:  # noqa: PLR2004
        return dict[Any, Any]
    return dict


def _parse_tuple_hint(type_str: str) -> Any:
    """Helper to parse tuple(T1, T2, ...)."""
    return tuple[Any, ...]


def normalize_schema(schema: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """
    Adjust schema items:
      - Convert types like string to valid type hints.
      - Convert lists of comparators ['>=0','<=100'] to min/max.
      - HTML unescape (&gt;,&lt;).
    """
    normalized: list[dict[str, Any]] = []
    for rule in schema:
        r = dict(rule)

        # Type can come as string (ex.: "dict(str, str)")
        if isinstance(r.get("type"), str):
            r["type"] = parse_type_hint(r["type"])

        _normalize_default_enum(r)
        _normalize_constraints(r)

        normalized.append(r)
    return normalized


def _normalize_default_enum(r: dict[str, Any]) -> None:
    """Normalize default value and enum options."""
    if "default" in r and isinstance(r["default"], list):
        r["enum"] = [_html_unescape(str(x)) for x in r["default"]]
        if len(r["enum"]) > 0:
            r["default"] = r["enum"][0]
        else:
            r.pop("default")


def _normalize_constraints(r: dict[str, Any]) -> None:
    """Normalize numeric constraints from lists or default strings."""
    for key in ("default", "constraints"):
        val = r.get(key)
        if isinstance(val, list):
            for token in val:
                _apply_comparator(r, str(token))

    # Also check if default itself is a string comparator
    default_val = r.get("default")
    if isinstance(default_val, str):
        if _apply_comparator(r, default_val):
            r.pop("default", None)


def _apply_comparator(r: dict[str, Any], token: str) -> bool:
    """Parse a comparator string and update min/max. Returns True if applied."""
    tok = _html_unescape(token).strip()
    applied = False
    try:
        if tok.startswith(">="):
            r["min"] = max(r.get("min", float("-inf")), float(tok[2:].strip()))
            applied = True
        elif tok.startswith("<="):
            r["max"] = min(r.get("max", float("inf")), float(tok[2:].strip()))
            applied = True
    except (ValueError, TypeError):
        pass
    return applied


# ------------------ Main Validation ------------------
def validate_json(
    data: dict[str, Any],
    schema: list[dict[str, Any]],
    sep: str = "_",
) -> list[str]:
    """
    Validate 'data' according to 'schema'.
    """
    errors: list[str] = []
    schema = normalize_schema(schema)

    for rule in schema:
        path: str = rule["path"]
        expected_type: Any = rule["type"]
        required: bool = rule.get("required", True)

        value, found = get_value_by_path(data, path, sep=sep)

        if not found:
            if required:
                errors.append(f"{path}: required field is missing.")
            continue

        _validate_value_rule(path, value, rule, expected_type, errors)

    return errors


def _validate_value_rule(
    path: str,
    value: Any,
    rule: dict[str, Any],
    expected_type: Any,
    errors: list[str],
) -> None:
    """Helper to validate a specific value against a rule."""
    allow_empty: bool = rule.get("allow_empty", False)
    expected_origin = get_origin(expected_type)

    for suffix, v in _iter_values(value, expected_origin):
        if not allow_empty and is_empty(v):
            errors.append(f"{path}{suffix}: cannot be null/empty.")
            continue

        if not check_type(v, expected_type):
            exp = getattr(expected_type, "__name__", str(expected_type))
            got = type(v).__name__
            errors.append(f"{path}{suffix}: invalid type. Expected {exp}, got {got}.")
            continue

        _check_constraints(path, suffix, v, rule, errors)


def _iter_values(val: Any, expected_origin: Any):
    """Iterate values, unwrapping traversal wrappers produced by get_value_by_path.

    get_value_by_path collects sub-values into an outer list when traversing
    through an intermediate list (e.g. template.containers is a list, so
    'template_containers_env' returns list[list[dict]] instead of list[dict]).

    Rules:
    - val is list AND expected is NOT list → traversal wrapper over scalar/dict;
      iterate each element individually.
    - val is list[list] AND expected IS list → traversal wrapper over a list field;
      iterate each inner list individually.
    - Otherwise → val is the actual value; yield as-is.
    """
    if isinstance(val, list) and expected_origin is not list:
        # Traversal wrapper over a non-list field (e.g. image, env_name)
        for idx, v in enumerate(val):
            yield f"[{idx}]", v
    elif (
        isinstance(val, list)
        and expected_origin is list
        and val  # non-empty
        and all(isinstance(v, list) for v in val)
    ):
        # Traversal wrapper over a list field (e.g. containers[*].env →
        # list[list[dict]])
        for idx, v in enumerate(val):
            yield f"[{idx}]", v
    else:
        yield "", val


def _check_constraints(
    path: str, suffix: str, v: Any, rule: dict[str, Any], errors: list[str]
) -> None:
    """Check constraints like enum, numeric range, regex, length."""
    _check_enum_constraint(path, suffix, v, rule, errors)
    _check_numeric_constraints(path, suffix, v, rule, errors)
    _check_string_constraints(path, suffix, v, rule, errors)
    _check_length_constraints(path, suffix, v, rule, errors)


def _check_enum_constraint(
    path: str, suffix: str, v: Any, rule: dict[str, Any], errors: list[str]
) -> None:
    """Check enum constraint."""
    enum = rule.get("enum")
    if enum is not None and v not in enum:
        msg = f"{path}{suffix}: value '{v}' not in allowed options: {enum}."
        errors.append(msg)


def _check_numeric_constraints(
    path: str, suffix: str, v: Any, rule: dict[str, Any], errors: list[str]
) -> None:
    """Check numeric constraints (min/max)."""
    min_val = rule.get("min")
    max_val = rule.get("max")
    if isinstance(v, (int, float)):
        if min_val is not None and v < min_val:
            errors.append(f"{path}{suffix}: {v} < minimum {min_val}.")
        if max_val is not None and v > max_val:
            errors.append(f"{path}{suffix}: {v} > maximum {max_val}.")
    elif min_val is not None or max_val is not None:
        errors.append(f"{path}{suffix}: min/max defined, but type is not numeric.")


def _check_string_constraints(
    path: str, suffix: str, v: Any, rule: dict[str, Any], errors: list[str]
) -> None:
    """Check string constraints (regex)."""
    regex = rule.get("regex")
    if regex:
        if isinstance(v, str):
            if not re.compile(regex).fullmatch(v):
                msg = f"{path}{suffix}: '{v}' does not match regex '{regex}'."
                errors.append(msg)
        else:
            errors.append(f"{path}{suffix}: 'regex' defined, but type is not string.")


def _check_length_constraints(
    path: str, suffix: str, v: Any, rule: dict[str, Any], errors: list[str]
) -> None:
    """Check length constraints (min_len/max_len)."""
    min_len = rule.get("min_len")
    max_len = rule.get("max_len")
    if min_len is not None or max_len is not None:
        if isinstance(v, (str, list, tuple, set)):
            _apply_length_checks(path, suffix, v, min_len, max_len, errors)
        else:
            errors.append(f"{path}{suffix}: min_len/max_len on unsupported type.")


def _apply_length_checks(  # noqa: PLR0913
    path: str,
    suffix: str,
    v: Any,
    min_len: int | None,
    max_len: int | None,
    errors: list[str],
) -> None:
    """Apply min/max length checks."""
    if min_len is not None and len(v) < min_len:
        errors.append(f"{path}{suffix}: length {len(v)} < min {min_len}.")
    if max_len is not None and len(v) > max_len:
        errors.append(f"{path}{suffix}: length {len(v)} > max {max_len}.")


def validate_entries(
    entries: list[dict[str, Any]], schema: list[dict[str, Any]], sep: str = "_"
):
    """Validates a dictionary of JSON files."""
    all_errors: list[str] = []
    for entry in entries:
        sys.stderr.write(f"INFO: Validating entries: {entry['source']}\n")
        # sys.stderr.write(f"DEBUG: Content keys: {list(entry['content'].keys())}\n")
        errs = validate_json(entry["content"], schema, sep=sep)
        all_errors.extend(errs)
    if all_errors:
        for e in all_errors:
            sys.stderr.write(f"ERROR: Validation failed: {e}\n")
        raise Exception("Validation failed.")
    # else:
    # sys.stderr.write(f"DEBUG: Entries validated without errors {entries}.\n")


# ------------------ Example usage ------------------
if __name__ == "__main__":
    input = {
        "nome": "Tatiana",
        "endereco": {"rua": "Av. Paulista", "numero": 100},
        "itens": ["A", "B"],
        "meta": {"ativo": True, "quantidade": 10},
        "tags": ["dados", "engenharia"],
        "coords": (23, -46),
        "extra": {"chave": 123},
        "marcadores": {"a", "b"},
        "preco": 19.99,
        "versatil": 42,
        "format": "DOCKER",
        "mode": "STANDARD_REPOSITORY",
        "value": 50,
    }

    schema = [
        {"path": "nome", "type": str, "required": True},
        {"path": "endereco_rua", "type": str, "required": True},
        {"path": "endereco_numero", "type": (int, str), "required": True},
        {"path": "itens", "type": list[str], "required": True, "allow_empty": False},
        {"path": "meta_ativo", "type": bool | None, "required": False},
        {"path": "meta_quantidade", "type": int, "required": True},
        {"path": "tags", "type": list[str], "required": False},
        {"path": "coords", "type": tuple[int, int], "required": False},
        {"path": "extra", "type": dict[str, int], "required": False},
        {"path": "marcadores", "type": set[str], "required": False},
        {"path": "preco", "type": float, "required": False},
        {"path": "versatil", "type": int | str, "required": False},
        {"path": "format", "type": str, "required": True, "enum": ["DOCKER", "MAVEN"]},
        {
            "path": "mode",
            "type": str,
            "required": True,
            "enum": ["STANDARD_REPOSITORY", "VIRTUAL_REPOSITORY", "REMOTE_REPOSITORY"],
        },
        {"path": "value", "type": int, "required": True, "min": 0, "max": 100},
    ]
    schema_typed = cast(list[dict[str, Any]], schema)
    erros = validate_json(input, schema_typed, sep="_")
    if erros:
        sys.stderr.write("Validation failed:")
        for e in erros:
            sys.stderr.write(f"- {e}")
    else:
        sys.stderr.write("Valid JSON!\n")
