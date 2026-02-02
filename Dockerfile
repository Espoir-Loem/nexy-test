
FROM python:3-slim


WORKDIR /app

COPY requirements.txt .
RUN python3 -m venv .venv && source .venv/bin/activate
RUN python3 -m pip install --upgrade pip && pip install -r requirements.txt

COPY . .
EXPOSE 3000

CMD ["nexy", "serve", "--host", "0.0.0.0"]