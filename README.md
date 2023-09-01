# Prisjakt Scraper

## Develop

### Prerequisites

* Python version 3.11.
* [Docker](https://www.docker.com/get-started/)

### Local database

You should create a local database instance with [docker](https://www.docker.com/get-started/): `docker compose up`. This will create a database available at `localhost:5555`. Then to populate the database with the right tables, run `poetry run alembic upgrade head`. To verify the database and table creation, run `docker exec -it prisjakt_scraper-db-1 psql -U postgres -d prisjaktscraperdb` and then (e. g.) `select * from procut;`

### Run code

1. Install [poetry](https://python-poetry.org/docs/#installation) on your system.
2. Install and initialize environment: `poetry install`
3. Create a local `.env` file. You can copy the sample file `cp .env.local .env`
4. Run the main script with poetry: `poetry run python prisjakt_scraper/main.py` or activate the environment with `poetry shell` and then run `python prisjakt_scraper/main.py`

### Test

Test with the command `python -m pytest -v` from the root folder (assuming you are in a poetry environment).

### Linting and formatting

There are currently no restrictions in place, but please ensure good code quality by following linting and formatting rules by `flake8`. To lint, run `pylint prisjakt_scaper`. To format, run `black .`.

## Connect to the production database

**Prerequisites**:
* An AWS user with proper access
* The [AWS CLI](https://aws.amazon.com/cli/) installed and configured
* The [AWS Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
* The [terraform CLI](https://developer.hashicorp.com/terraform/downloads) installed locally

Run `./db_connection.sh` from the root of the repository and then use your favorite DB client to connect to the database. Credentials are outputted from the script.

## Run scraiping task on demand in the cloud

If for some reason you need to run the scraping task apart from the schedule, run the script `./invoke_task.sh`.