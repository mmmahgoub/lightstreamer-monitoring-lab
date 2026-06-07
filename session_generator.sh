#!/usr/bin/env bash
set -euo pipefail

DEFAULT_HOST="$(minikube ip 2>/dev/null || true)"
TARGET_HOST="${LIGHTSTREAMER_HOST:-${DEFAULT_HOST:-127.0.0.1}}"
TARGET_PORT="${LIGHTSTREAMER_PORT:-30080}"
TARGET_URL="${LIGHTSTREAMER_URL:-http://${TARGET_HOST}:${TARGET_PORT}/lightstreamer/create_session.txt}"
PROTOCOL="TLCP-2.0.0"
ADAPTER_SET="DEMO"
CLIENT_ID="demo_bench_client_$(date +%s)"

# Number of concurrent active sessions you want to mock
NUM_SESSIONS=35
# How long each session should hold the streaming connection open (in seconds)
SESSION_DURATION=45

if [[ "$TARGET_URL" == http://127.0.0.1* ]] && [[ -n "${DEFAULT_HOST}" ]]; then
  echo "Warning: using localhost as LIGHTSTREAMER host."
  echo "If this script is running outside Minikube, set LIGHTSTREAMER_HOST or LIGHTSTREAMER_URL."
fi

echo "Starting session generator. Simulating $NUM_SESSIONS concurrent connections..."

echo "Using target URL: $TARGET_URL"

for i in $(seq 1 $NUM_SESSIONS); do
  curl -s -N -X POST \
    -d "LS_adapter_set=${ADAPTER_SET}&LS_cid=${CLIENT_ID}_$i" \
    "${TARGET_URL}?LS_protocol=${PROTOCOL}" > /dev/null &
done

sleep $SESSION_DURATION

echo "Sessions expired. Cleaning up."
kill $(jobs -p) 2>/dev/null || true