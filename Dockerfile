FROM python:3.11-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml package*.json ./
RUN uv sync

RUN npm i

COPY . .

RUN uv run nexy build

FROM python:3.11-slim

RUN groupadd -r nexygroup && useradd -r -g nexygroup nexyuser

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY --from=builder --chown=nexyuser:nexygroup /app/.venv /app/.venv
COPY --from=builder --chown=nexyuser:nexygroup /app/__nexy__ /app/__nexy__

COPY --chown=nexyuser:nexygroup . .

RUN mkdir -p /app/.cache/uv /app/.local/share/uv && \
    chown -R nexyuser:nexygroup /app/.cache /app/.local

USER nexyuser

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV UV_CACHE_DIR=/app/.cache/uv
ENV UV_DATA_DIR=/app/.local/share/uv
ENV UV_PYTHON_DOWNLOADS=never

EXPOSE 3000

CMD ["uv", "run", "nexy", "start"]