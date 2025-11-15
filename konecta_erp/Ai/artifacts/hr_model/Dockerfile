FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Prefer prebuilt wheels; fall back to source only if needed
RUN python -m pip install --upgrade --no-cache-dir pip setuptools wheel && \
    pip install --no-cache-dir --disable-pip-version-check --no-compile \
        --only-binary=:all: \
        numpy pandas scikit-learn xgboost joblib \
    || pip install --no-cache-dir --disable-pip-version-check --no-compile \
        numpy pandas scikit-learn xgboost joblib

# Copy only the artifacts actually needed
COPY hr_scaler.pkl ./
COPY hr_xgb_model.pkl ./
COPY hr_feature_columns.csv ./

CMD ["bash"]
