from pathlib import Path

src = Path("{{cookiecutter.project_slug}}")
# {% if cookiecutter.has_cli != "y" %}
(src / "cli.py").unlink(missing_ok=True)
# {% endif %}
