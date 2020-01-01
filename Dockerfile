FROM python:3.8.1-slim-buster
LABEL maintainer="Nick Janetakis <nick.janetakis@gmail.com>"

WORKDIR /app

COPY requirements.txt requirements.txt

ENV BUILD_DEPS="build-essential" \
    APP_DEPS="curl libpq-dev"

RUN apt-get update \
  && apt-get install -y ${BUILD_DEPS} ${APP_DEPS} --no-install-recommends \
  && pip install -r requirements.txt \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /usr/share/doc && rm -rf /usr/share/man \
  && apt-get purge -y --auto-remove ${BUILD_DEPS} \
  && apt-get clean

ARG FLASK_ENV="production"
ENV FLASK_ENV="${FLASK_ENV}" \
    FLASK_APP="snakeeyes.app" \
    PYTHONUNBUFFERED="true"

COPY . .

RUN pip install --editable .

RUN if [ "${FLASK_ENV}" != "development" ]; then \
  flask digest compile; fi

EXPOSE 8000

CMD ["gunicorn", "-c", "python:config.gunicorn", "snakeeyes.app:create_app()"]
