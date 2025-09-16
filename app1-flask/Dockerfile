FROM python:3.12-slim

# Non-root
RUN useradd -m -u 10001 appuser

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1     PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends     curl ca-certificates build-essential     && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py ./

EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD curl -fsS http://localhost:5000/health || exit 1

USER appuser

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "app:app"]
