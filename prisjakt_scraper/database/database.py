from contextlib import contextmanager
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, inspect
from prisjakt_scraper.database.environment import db_uri
from prisjakt_scraper.logger.logger import logger
from prisjakt_scraper.logger.config import DB_LOG_STREAM_NAME

engine = create_engine(f"{db_uri}", echo=True, logging_name=DB_LOG_STREAM_NAME)
Session = sessionmaker(bind=engine)


class SessionException(Exception):
    pass


@contextmanager
def session_scope():
    session = Session()
    try:
        yield session
        session.commit()
        logger.info("Database session committed")
    except BaseException:
        session.rollback()
        logger.error("Database session rollbacked")
        raise
    finally:
        session.close()


def db_session(func):
    def wrapper(*args, **kwargs):
        with session_scope() as session:
            return func(session, *args, **kwargs)

    return wrapper


def check_database_connection():
    connection = None
    try:
        table_that_should_exist = "product"
        connection = engine.connect()
        if not inspect(engine).has_table(table_that_should_exist):
            raise SessionException(
                f"Table {table_that_should_exist} does not exist. Have you run migrations?"
            )
        logger.info("Successfully connected to database")
    except BaseException as operational_error:
        logger.error("Database connection error: %s", operational_error)
        raise SessionException(operational_error) from operational_error
    finally:
        connection.close()
