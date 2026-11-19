#!/bin/bash
set -euo pipefail

branch=$(git branch --show-current)
if [ -z "$branch" ]; then
  echo "detached HEAD: check out a branch, its name is the image tag" >&2
  exit 1
fi
image=${IMAGE:-ceymard/postgres-convenient:$branch}

docker build --progress=plain --rm -t "$image" .

# Smoke test: every extension can be created, and postcbor answers a query.
container=$(docker run -d -e POSTGRES_PASSWORD=test -e POSTGRES_DB=app "$image")
trap 'docker rm -f "$container" >/dev/null' EXIT

for _ in $(seq 60); do
  # The entrypoint restarts the server after init; wait for the final one on TCP.
  docker exec "$container" pg_isready -h 127.0.0.1 -U postgres >/dev/null 2>&1 && break
  sleep 1
done

docker exec -i "$container" psql -h 127.0.0.1 -U postgres -d app -v ON_ERROR_STOP=1 <<'SQL'
CREATE EXTENSION pg_cron;
CREATE EXTENSION http;
CREATE EXTENSION envvar;
CREATE EXTENSION postgis;
CREATE EXTENSION pg_jsonschema;
CREATE EXTENSION postcbor;
CREATE EXTENSION pljs;
DO $$ pljs.elog(NOTICE, "pljs ok") $$ LANGUAGE pljs;
SELECT '{"name": "ann", 1: h''cafe''}'::cbor -> 1 AS postcbor_check;
SELECT postgis_full_version();
SQL
echo "smoke test passed: $image"
