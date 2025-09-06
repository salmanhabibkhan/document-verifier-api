# syntax=docker/dockerfile:1
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Keep the parent of the 'app' package as the working dir
WORKDIR /srv

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY app/requirements.txt /srv/requirements.txt
RUN pip install -r /srv/requirements.txt

# Copy the package directory
COPY app /srv/app

# Ensure Python can import 'app' package
ENV PYTHONPATH=/srv

EXPOSE 8000
ENV PORT=8000

# Point gunicorn to the package module
CMD ["gunicorn", "-c", "app/gunicorn_conf.py", "app.main:app"]