import logging as _logging

import structlog


def logging(**kwargs):
    if structlog.is_configured():
        return
    kwargs.setdefault("level", _logging.INFO)
    kwargs.setdefault("format", "%(message)s")
    _logging.basicConfig(**kwargs)

    config = structlog.get_config()
    structlog.configure(
        processors=[
            structlog.stdlib.add_logger_name,
            *config["processors"],
        ],
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )
