# --- Étape 1 : Builder (Python + Bun) ---
FROM python:3.11-slim AS builder

# Installation de uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Installation de Bun (plus léger et rapide que Node)
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip && \
    curl -fsSL https://bun.sh/install | bash && \
    cp /root/.bun/bin/bun /usr/local/bin/bun && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installation des dépendances (Python via uv, JS via Bun)
COPY pyproject.toml uv.lock* bun.lockb* package.json ./
RUN uv sync
# 'bun install --frozen-lockfile' est l'équivalent de 'npm ci'
RUN bun install --frozen-lockfile

# Build de Nexy
COPY . .
RUN uv run nexy build

# --- Étape 2 : Runtime ---
FROM python:3.11-slim

RUN groupadd -r nexygroup && useradd -r -g nexygroup nexyuser

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Récupération des artefacts
COPY --from=builder --chown=nexyuser:nexygroup /app/.venv /app/.venv
COPY --from=builder --chown=nexyuser:nexygroup /app/__nexy__ /app/__nexy__
COPY --chown=nexyuser:nexygroup . .

USER nexyuser

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
EXPOSE 3000

CMD ["uv", "run", "nexy", "start"]