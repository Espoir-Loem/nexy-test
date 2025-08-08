import os
import sys


# Assure que la racine du projet est dans sys.path pour importer nexyconfig
CURRENT_DIR = os.path.dirname(__file__)
PROJECT_ROOT = os.path.dirname(CURRENT_DIR)
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)


# Expose l'application Nexy comme WSGI/ASGI app pour Vercel
from nexyconfig import app  # noqa: E402



