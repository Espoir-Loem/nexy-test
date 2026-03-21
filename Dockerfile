# --- Étape 1 : Builder ---
FROM python:3.11-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Ajout de --no-install-recommends pour un build plus rapide et léger
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Optimisation stricte du cache
COPY pyproject.toml uv.lock package*.json ./
RUN uv sync --frozen
# Utilisation de npm ci pour un build strictement déterministe
RUN npm ci 

# Copie du code source
COPY . .

# Exécution du build
RUN uv run nexy build

# --- Étape 2 : Runtime ---
FROM python:3.11-slim

# Création d'un utilisateur non-root pour la sécurité en production
RUN groupadd -r nexygroup && useradd -r -g nexygroup nexyuser

# On ne récupère uv que si c'est strictement nécessaire pour la commande finale
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Copie des artefacts avec attribution des droits au nouvel utilisateur
COPY --from=builder --chown=nexyuser:nexygroup /app/.venv /app/.venv
COPY --from=builder --chown=nexyuser:nexygroup /app/__nexy__ /app/__nexy__

# IMPORTANT : Ne copiez QUE les fichiers strictement nécessaires à l'exécution de Nexy.
# Par exemple, si vous avez besoin d'un fichier de configuration ou d'un dossier public :
# COPY --chown=nexyuser:nexygroup nexy.config.py ./
# Si Nexy a besoin de lire les sources brutes au runtime, utilisez COPY avec un .dockerignore strict.
COPY --chown=nexyuser:nexygroup . .

# Changement d'utilisateur (Fin des privilèges root)
USER nexyuser

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
EXPOSE 3000

CMD ["uv", "run", "nexy", "start"]