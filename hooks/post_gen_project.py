from pathlib import Path
import subprocess

cwd = Path.cwd()
src = cwd / "{{cookiecutter.project_slug}}"
# {% if cookiecutter.has_cli != "y" %}
(src / "cli.py").unlink(missing_ok=True)
# {% endif %}
subprocess.check_call(["poetry", "lock"])
subprocess.check_call(["nix", "flake", "lock"])
