FROM python:3.11-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip && \
    curl -fsSL https://bun.sh/install | bash && \
    cp /root/.bun/bin/bun /usr/local/bin/bun && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml  package.json ./
RUN uv sync
RUN bun install 

COPY . .
RUN uv run nexy build

FROM python:3.11-slim

RUN groupadd -r nexygroup && useradd -r -g nexygroup nexyuser

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY --from=builder --chown=nexyuser:nexygroup /app/.venv /app/.venv
COPY --from=builder --chown=nexyuser:nexygroup /app/__nexy__ /app/__nexy__
COPY --chown=nexyuser:nexygroup . .

USER nexyuser

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
EXPOSE 3000

CMD ["uv", "run", "nexy", "start"]