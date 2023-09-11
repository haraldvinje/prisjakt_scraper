ARG APP_NAME=prisjakt_scraper
ARG APP_PATH=/opt/$APP_NAME
ARG PYTHON_VERSION=3.11.5
ARG POETRY_VERSION=1.3.2

FROM python:$PYTHON_VERSION as staging
ARG APP_NAME
ARG APP_PATH
ARG POETRY_VERSION

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1
ENV \
    POETRY_VERSION=$POETRY_VERSION \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1

# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python -
ENV PATH="$POETRY_HOME/bin:$PATH"

# Import project files
WORKDIR $APP_PATH
COPY ./poetry.lock ./pyproject.toml ./
COPY ./$APP_NAME ./$APP_NAME
COPY ./alembic ./alembic
COPY ./alembic.ini ./alembic.ini
COPY ./.env ./.env

# Install chrome to run webdriver
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

FROM staging as development
ARG APP_NAME
ARG APP_PATH

WORKDIR $APP_PATH
RUN poetry install

ARG START_COMMAND="cd ${APP_PATH} && poetry run alembic upgrade head && poetry run python ${APP_NAME}/main.py"
RUN echo ${START_COMMAND} >> run.sh
RUN chmod +x run.sh

ENTRYPOINT ["/bin/sh", "run.sh"]