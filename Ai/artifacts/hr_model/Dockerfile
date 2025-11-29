FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /build

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN python -m pip install --upgrade --no-cache-dir pip setuptools wheel && \
    pip install --no-cache-dir --disable-pip-version-check --no-compile \
        --only-binary=:all: \
        numpy pandas scikit-learn xgboost joblib \
    || pip install --no-cache-dir --disable-pip-version-check --no-compile \
        numpy pandas scikit-learn xgboost joblib

# Runtime stage
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.local/bin:$PATH"

WORKDIR /app

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy only installed packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy only the artifacts actually needed
COPY --chown=appuser:appuser hr_scaler.pkl ./
COPY --chown=appuser:appuser hr_xgb_model.pkl ./
COPY --chown=appuser:appuser hr_feature_columns.csv ./

USER appuser

CMD ["bash"]
