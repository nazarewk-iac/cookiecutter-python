import structlog

# {% if cookiecutter.has_trio != "y" %}
import click

# {% else %}
import asyncclick as click

# {% endif %}

logger: structlog.stdlib.BoundLogger = structlog.get_logger()


@click.command(
    context_settings=dict(
        show_default=True,
        auto_envvar_prefix="{{ cookiecutter.env_prefix }}",
    ),
)
# {% if cookiecutter.has_trio != "y" %}
def main():
    logger.warning("Hello, world!", has_trio=False)


# {% else %}
async def main():
    logger.warning("Hello, async world!", has_trio=True)


# {% endif %}


if __name__ == "__main__":
    main(
        # {% if cookiecutter.has_trio == "y" %}
        _anyio_backend="trio",
        # {% endif %}
    )
