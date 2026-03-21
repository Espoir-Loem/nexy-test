# --- Étape 1 : Builder ---
FROM python:3.11-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Optimisation du cache : on copie les fichiers de dépendances d'abord
COPY pyproject.toml package*.json ./
# Note : j'ai retiré uv.lock car tes logs indiquaient qu'il était parfois absent
RUN uv sync 

RUN npm install

COPY . .

RUN uv run nexy build

# --- Étape 2 : Runtime ---
FROM python:3.11-slim

# CORRECTION : Création de l'utilisateur avec un répertoire personnel (-m)
RUN groupadd -r nexygroup && useradd -r -m -g nexygroup nexyuser

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Récupération des artefacts avec les bonnes permissions
COPY --from=builder --chown=nexyuser:nexygroup /app/.venv /app/.venv
COPY --from=builder --chown=nexyuser:nexygroup /app/__nexy__ /app/__nexy__
COPY --chown=nexyuser:nexygroup . .

USER nexyuser

# CONFIGURATION : On force le cache dans /tmp par sécurité
ENV UV_CACHE_DIR=/tmp/.uv_cache
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
EXPOSE 3000

# Lancement avec --no-cache car tout est déjà prêt dans .venv
CMD ["uv", "run", "--no-cache", "nexy", "start"]