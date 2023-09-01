import sys
from logging import getLogger, Formatter, StreamHandler, Logger
from dotenv import load_dotenv
from prisjakt_scraper.logger.config import (
    APP_LOG_STREAM_NAME,
    DB_LOG_STREAM_NAME,
    APP_LOG_LEVEL,
    DB_LOG_LEVEL,
    formatter,
)

load_dotenv()

app_logger = getLogger(APP_LOG_STREAM_NAME)
app_logger.setLevel(APP_LOG_LEVEL)

db_log_name = f"sqlalchemy.engine.Engine.{DB_LOG_STREAM_NAME}"
db_logger = getLogger(db_log_name)
db_logger.setLevel(DB_LOG_LEVEL)


def configure_stdout_handler(log: Logger, fmt: Formatter) -> StreamHandler:
    log_handler = StreamHandler(sys.stdout)
    log_handler.setFormatter(fmt)
    log_handler.setLevel(log.level)
    return log_handler


app_log_handler = configure_stdout_handler(app_logger, formatter)
db_log_handler = configure_stdout_handler(db_logger, formatter)

if not app_logger.handlers:
    app_logger.addHandler(app_log_handler)

if not db_logger.handlers:
    db_logger.addHandler(db_log_handler)

logger = app_logger
