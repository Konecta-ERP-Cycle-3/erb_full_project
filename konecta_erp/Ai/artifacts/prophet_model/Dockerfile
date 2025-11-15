FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN python -m pip install --upgrade --no-cache-dir pip setuptools wheel && \
    pip install --no-cache-dir --disable-pip-version-check --no-compile \
        --only-binary=:all: \
        pandas prophet joblib \
    || pip install --no-cache-dir --disable-pip-version-check --no-compile \
        pandas prophet joblib

COPY prophet_model.pkl ./
COPY prophet_forecast.csv ./

CMD ["bash"]
