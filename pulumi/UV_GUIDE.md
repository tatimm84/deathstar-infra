# Using UV with Pulumi - Quick Guide

## What is UV?

**uv** is an ultrafast Python package manager written in Rust, offering 10-100x faster dependency installation compared to pip. Pulumi has native support for uv.

## Installation

### Windows (PowerShell)

```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Linux/macOS

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Usage

### First Time Setup

```bash
cd pulumi/

# Install dependencies (creates .venv automatically)
uv sync

# Activate virtual environment (if needed)
# Windows
.venv\Scripts\activate

# Linux/macOS
source .venv/bin/activate
```

### Daily Workflow

```bash
cd pulumi/

# Update dependencies
uv sync

# Run Pulumi commands
pulumi preview
pulumi up
```

### Adding Dependencies

```bash
# Add a new package
uv add package-name

# Add with version constraint
uv add "package-name>=1.0.0,<2.0.0"

# Remove a package
uv remove package-name
```

## Benefits

✅ **10-100x faster** than pip
✅ **Automatic virtual environment** management
✅ **Lock file** (`uv.lock`) for reproducible builds
✅ **Native Pulumi support**
✅ **Drop-in replacement** for pip

## Files

- **`pyproject.toml`** - Project configuration and dependencies
- **`uv.lock`** - Lock file (auto-generated, commit to git)
- **`.venv/`** - Virtual environment (auto-created, don't commit)
- **`requirements.txt`** - Legacy pip format (kept for compatibility)

## Pipeline Integration

The Azure DevOps pipeline automatically:

1. Installs uv
2. Runs `uv sync` to install dependencies
3. Uses the virtual environment for Pulumi commands

No manual configuration needed!

## Troubleshooting

### "uv: command not found"

```bash
# Reinstall uv
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Or add to PATH manually
# Windows: Add %USERPROFILE%\.cargo\bin to PATH
```

### "No pyproject.toml found"

```bash
# Make sure you're in the pulumi/ directory
cd pulumi/
uv sync
```

### Fallback to pip

If uv has issues, you can always use pip:

```bash
pip install -r requirements.txt
```

## Learn More

- [UV Documentation](https://docs.astral.sh/uv/)
- [Pulumi UV Support](https://www.pulumi.com/docs/languages-sdks/python/#uv)
- [UV GitHub](https://github.com/astral-sh/uv)
