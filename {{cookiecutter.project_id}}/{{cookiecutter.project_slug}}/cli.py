import structlog
# {% if cookiecutter.has_trio != "y" %}
import click
# {% else %}
import asyncclick as click
# {% endif %}

from . import configure

configure.logging()
logger: structlog.stdlib.BoundLogger = structlog.get_logger()


@click.command(
    context_settings={"show_default": True},
)
# {% if cookiecutter.has_trio != "y" %}
def main():
    logger.warning("Hello, world!", has_trio=False)


# {% else %}
async def main():
    logger.warning("Hello, world!", has_trio=True)


# {% endif %}


if __name__ == "__main__":
    # {% if cookiecutter.has_trio == "y" %}
    main(_anyio_backend="trio")
    # {% else %}
    main()
    # {% endif %}
