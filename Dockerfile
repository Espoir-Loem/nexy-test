
FROM python:3-slim


WORKDIR /app

COPY requirements.txt .

RUN pip3 install --upgrade pip3 && pip3 install -r requirements.txt

COPY . .
EXPOSE 3000

CMD ["nexy", "serve", "--host", "0.0.0.0"]