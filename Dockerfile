# --- Étape 1 : Builder ---
FROM python:3.11-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Installation des dépendances système (Node.js pour Vite)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Optimisation du cache : on installe les libs avant de copier tout le code
COPY pyproject.toml uv.lock package*.json ./
RUN uv sync --frozen
RUN npm install

# Copie du code source
COPY . .

# Exécution du build (génère le dossier __nexy__)
RUN uv run nexy build

# --- Étape 2 : Runtime ---
FROM python:3.11-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Récupération des artefacts du builder
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/__nexy__ /app/__nexy__
COPY . .

# Configuration
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
EXPOSE 3000

# Lancement
CMD ["uv", "run", "nexy", "start"]