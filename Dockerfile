# Utilisation de Debian Bookworm pour plus de stabilité sur les dépendances système
FROM python:3.11-slim-bookworm AS builder

# Installation de UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Optimisation de l'installation des dépendances système
# On sépare pour mieux gérer le cache et éviter la saturation RAM
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Stratégie de mise en cache UV & NPM
COPY pyproject.toml package*.json ./
RUN uv sync  && npm i

# Build de l'application
COPY . .
RUN uv run nexy build

# --- Stage Final ---
FROM python:3.11-slim-bookworm

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Récupération stricte du nécessaire
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/__nexy__ /app/__nexy__
# On ne copie que les fichiers nécessaires à l'exécution, pas tout le contexte
COPY pyproject.toml ./ 

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    UV_PYTHON_DOWNLOADS=never

EXPOSE 3000

# Utilisation directe du venv pour de meilleures performances au démarrage
CMD ["nexy", "start"]