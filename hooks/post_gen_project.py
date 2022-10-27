from pathlib import Path

src = Path("{{cookiecutter.project_slug}}")
# {% if not cookiecutter.has_cli %}
(src / "cli.py").unlink(missing_ok=True)
# {% endif %}
