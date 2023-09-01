import os
import json
from typing import NamedTuple
from dotenv import load_dotenv
from botocore.exceptions import ClientError
import boto3
from prisjakt_scraper.logger.logger import logger

load_dotenv()


class DatabaseCredentials(NamedTuple):
    username: str
    password: str


def get_database_credentials() -> DatabaseCredentials:
    secret_name = os.getenv("DB_SECRET_NAME")
    region_name = os.getenv("AWS_REGION")

    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    try:
        secret_response = json.loads(
            client.get_secret_value(SecretId=secret_name)["SecretString"]
        )
        return DatabaseCredentials(
            username=secret_response["username"], password=secret_response["password"]
        )
    except ClientError as error:
        logger.error("Could not receive database credentials")
        raise error


db_dialect = os.getenv("DB_DIALECT", "postgresql")
db_host = os.getenv("DB_HOST", "localhost:5432")
db_name = os.getenv("DB_NAME", "database")

app_env = os.getenv("APP_ENV")
if app_env == "production":
    db_credentials = get_database_credentials()
    DB_USERNAME = db_credentials.username
    DB_PASSWORD = db_credentials.password
elif app_env == "local":
    DB_USERNAME = "postgres"
    DB_PASSWORD = "password"
else:
    DB_USERNAME = "postgres"
    DB_PASSWORD = "password"

db_uri = f"{db_dialect}://{DB_USERNAME}:{DB_PASSWORD}@{db_host}/{db_name}"
