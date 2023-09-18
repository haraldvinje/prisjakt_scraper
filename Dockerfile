ARG APP_NAME=prisjakt_scraper
ARG APP_PATH=/opt/$APP_NAME
ARG PYTHON_VERSION=3.11.5
ARG POETRY_VERSION=1.3.2

# Use an official Python runtime as a parent image
FROM python:$PYTHON_VERSION

ENV POETRY_HOME="/opt/poetry"

# Install system dependencies for Chrome and Poetry
RUN apt-get update -y && \
    apt-get install -yqq \
    curl \
    wget \
    tree \
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

# Define the command to run your application
# CMD ["pwd"]
CMD ["poetry", "run", "python", "prisjakt_scraper/main.py"]
