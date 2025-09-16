import express from "express";
import Redis from "ioredis";
import client from "prom-client";
import pino from "pino";

const app = express();
const logger = pino();

const REDIS_HOST = process.env.REDIS_HOST || "localhost";
const REDIS_PORT = parseInt(process.env.REDIS_PORT || "6379", 10);
const CACHE_TTL = parseInt(process.env.APP_CACHE_TTL || "60", 10);
const SERVICE_NAME = process.env.SERVICE_NAME || "app2-express";

const redis = new Redis({ host: REDIS_HOST, port: REDIS_PORT, connectTimeout: 1000, lazyConnect: false });

const register = new client.Registry();
client.collectDefaultMetrics({ register });

const requests = new client.Counter({ name: "app_requests_total", help: "Total HTTP requests", labelNames: ["service", "endpoint"] });
const cacheHits = new client.Counter({ name: "app_cache_hits_total", help: "Cache hits", labelNames: ["service", "endpoint"] });
const cacheMisses = new client.Counter({ name: "app_cache_misses_total", help: "Cache misses", labelNames: ["service", "endpoint"] });
const latency = new client.Histogram({ name: "app_request_latency_seconds", help: "Request latency", labelNames: ["service", "endpoint"] });

register.registerMetric(requests);
register.registerMetric(cacheHits);
register.registerMetric(cacheMisses);
register.registerMetric(latency);

async function cached(key, ttl, computeFn, endpoint) {
  const start = Date.now();
  try {
    const cachedVal = await redis.get(key);
    if (cachedVal !== null) {
      cacheHits.labels(SERVICE_NAME, endpoint).inc();
      latency.labels(SERVICE_NAME, endpoint).observe((Date.now() - start) / 1000);
      return cachedVal;
    }
    cacheMisses.labels(SERVICE_NAME, endpoint).inc();
    const result = await computeFn();
    try {
      await redis.setex(key, ttl, result);
    } catch (e) {
      logger.warn({ e, endpoint }, "cache_set_failed");
    }
    return result;
  } catch (e) {
    cacheMisses.labels(SERVICE_NAME, endpoint).inc();
    logger.warn({ e, endpoint }, "cache_unavailable");
    return await computeFn();
  }
}

app.get("/hello", async (req, res) => {
  requests.labels(SERVICE_NAME, "/hello").inc();
  const result = await cached("app2:hello", CACHE_TTL, async () => "Olá do App2 (Express)!", "/hello");
  logger.info({ service: SERVICE_NAME, route: "/hello" }, "handled");
  res.type("text/plain").send(result);
});

app.get("/time", async (req, res) => {
  requests.labels(SERVICE_NAME, "/time").inc();
  const result = await cached("app2:time", CACHE_TTL, async () => `App2 time: ${new Date().toISOString()}`, "/time");
  logger.info({ service: SERVICE_NAME, route: "/time" }, "handled");
  res.type("text/plain").send(result);
});

app.get("/health", (req, res) => {
  res.json({ status: "ok", service: SERVICE_NAME });
});

app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

const port = process.env.PORT || 3000;
app.listen(port, "0.0.0.0", () => {
  logger.info({ service: SERVICE_NAME, port }, "app started");
});
