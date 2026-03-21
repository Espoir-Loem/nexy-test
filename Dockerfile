FROM python:3.11-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml package*.json ./
RUN uv sync  && npm i

COPY . .
RUN uv run nexy build

FROM python:3.11-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY --from=builder /app/.venv    /app/.venv
COPY --from=builder /app/__nexy__ /app/__nexy__
COPY . .

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_CACHE_DIR=/app/.cache/uv \
    UV_DATA_DIR=/app/.local/share/uv

EXPOSE 3000

CMD ["uv", "run", "nexy", "start"]