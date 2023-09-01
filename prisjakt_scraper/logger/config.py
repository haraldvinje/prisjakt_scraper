import os
from logging import Formatter, INFO, DEBUG, WARNING, ERROR, CRITICAL

from dotenv import load_dotenv

load_dotenv()

LOG_FORMAT = "{levelname} [{name}] {message}"
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
FORMAT_STYLE = "{"


class LocalFormatter(Formatter):
    grey = "\x1b[38;20m"
    yellow = "\x1b[33;20m"
    red = "\x1b[31;20m"
    bold_red = "\x1b[31;1m"
    reset = "\x1b[0m"
    dateformat = DATE_FORMAT

    FORMATS = {
        DEBUG: grey + LOG_FORMAT + reset,
        INFO: grey + LOG_FORMAT + reset,
        WARNING: yellow + LOG_FORMAT + reset,
        ERROR: red + LOG_FORMAT + reset,
        CRITICAL: bold_red + LOG_FORMAT + reset,
    }

    def format(self, record):
        log_fmt = self.FORMATS.get(record.levelno)
        return Formatter(log_fmt, datefmt=self.dateformat, style=FORMAT_STYLE).format(
            record
        )


APP_LOG_STREAM_NAME = "app"
DB_LOG_STREAM_NAME = "database"
APP_LOG_LEVEL = os.getenv("APP_LOG_LEVEL", "INFO")
DB_LOG_LEVEL = os.getenv("DB_LOG_LEVEL", "WARNING")

app_env = os.getenv("APP_ENV", "local")
if app_env == "local":
    formatter = LocalFormatter()
else:
    formatter = Formatter(LOG_FORMAT, DATE_FORMAT, style=FORMAT_STYLE)
