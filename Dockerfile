FROM python:3.12.4

ARG APP_NAME=prisjakt_scraper
ARG APP_PATH=/opt/$APP_NAME
ARG POETRY_VERSION=1.3.2

# Install system dependencies for Chrome and Poetry
RUN apt-get update -y && \
    apt-get install -yqq \
    curl \
    wget \
    unzip \
    gnupg \
    && apt-get clean

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update -y && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
ENV \
    POETRY_VERSION=$POETRY_VERSION \
    POETRY_HOME="/opt/poetry"
RUN curl -sSL https://install.python-poetry.org | python -
ENV PATH="$POETRY_HOME/bin:$PATH"

# Import project files
WORKDIR $APP_PATH
COPY ./poetry.lock ./pyproject.toml ./
COPY ./$APP_NAME ./$APP_NAME
COPY ./alembic ./alembic
COPY ./alembic.ini ./alembic.ini
COPY ./.env ./.env

WORKDIR $APP_PATH
RUN poetry install

ARG START_COMMAND="cd ${APP_PATH} && poetry run alembic upgrade head && poetry run python ${APP_NAME}/main.py"
RUN echo ${START_COMMAND} >> run.sh
RUN chmod +x run.sh

ENTRYPOINT ["/bin/sh", "run.sh"]