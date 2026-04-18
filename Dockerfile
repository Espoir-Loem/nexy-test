# --- Étape 1 : Builder ---
FROM python:3.11-slim-bookworm AS builder

# Installation de uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Copie des fichiers de définition (optimisation cache)
COPY pyproject.toml uv.lock ./

# Installation des dépendances dans un venv
# --no-install-project permet d'installer les libs sans le code source pour le cache
RUN uv sync 

# --- Étape 2 : Runtime ---
FROM python:3.11-slim-bookworm

WORKDIR /app

# Récupération du venv et des binaires depuis le builder
COPY --from=builder /app/.venv /app/.venv

# Copie du code source et des fichiers nécessaires
COPY . .

# Configuration de l'environnement
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    UV_PYTHON_DOWNLOADS=never

EXPOSE 3000

# Exécution
CMD ["nexy", "start"]