import os
import json
import time
from datetime import datetime, timezone
from flask import Flask, Response
import redis
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
CACHE_TTL = int(os.getenv("APP_CACHE_TTL", "10"))
SERVICE_NAME = os.getenv("SERVICE_NAME", "app1-flask")

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True, socket_connect_timeout=1, socket_timeout=1)

REQUESTS = Counter("app_requests_total", "Total HTTP requests", ["service", "endpoint"])
CACHE_HITS = Counter("app_cache_hits_total", "Cache hits", ["service", "endpoint"])
CACHE_MISSES = Counter("app_cache_misses_total", "Cache misses", ["service", "endpoint"])
LATENCY = Histogram("app_request_latency_seconds", "Request latency", ["service", "endpoint"])

app = Flask(__name__)

def json_log(message, **kwargs):
    payload = {"service": SERVICE_NAME, "message": message, "ts": int(time.time()), **kwargs}
    print(json.dumps(payload), flush=True)

def cached(key, ttl, compute_fn, endpoint):
    try:
        val = r.get(key)
        if val is not None:
            CACHE_HITS.labels(service=SERVICE_NAME, endpoint=endpoint).inc()
            return val
        CACHE_MISSES.labels(service=SERVICE_NAME, endpoint=endpoint).inc()
        result = compute_fn()
        try:
            r.setex(key, ttl, result)
        except Exception:
            json_log('cache_set_failed', endpoint=endpoint)
        return result
    except Exception:
        CACHE_MISSES.labels(service=SERVICE_NAME, endpoint=endpoint).inc()
        json_log('cache_unavailable', endpoint=endpoint)
        return compute_fn()

@app.route("/hello")
def hello():
    REQUESTS.labels(service=SERVICE_NAME, endpoint="/hello").inc()
    def compute():
        return "Olá do App1 (Flask)!"
    body = cached("app1:hello", CACHE_TTL, compute, "/hello")
    return Response(body, mimetype="text/plain")

@app.route("/time")
def current_time():
    REQUESTS.labels(service=SERVICE_NAME, endpoint="/time").inc()
    def compute():
        now = datetime.now(timezone.utc).astimezone().isoformat()
        return f"App1 time: {now}"
    body = cached("app1:time", CACHE_TTL, compute, "/time")
    return Response(body, mimetype="text/plain")

@app.route("/health")
def health():
    return {"status": "ok", "service": SERVICE_NAME}, 200

@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
