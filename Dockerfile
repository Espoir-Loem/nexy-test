
FROM python:3-alpine


WORKDIR /app

COPY requirements.txt .

RUN python -m venv .venv && . .venv/bin/activate
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . .
EXPOSE 3000

CMD ["nexy", "serve", "--host", "0.0.0.0"]