#!/bin/bash

TARGET_URL="http://localhost:8080/lightstreamer/create_session.txt"
PROTOCOL="TLCP-2.0.0"
ADAPTER_SET="DEMO"
CLIENT_ID="demo_bench_client_$(date +%s)"

# Number of concurrent active sessions you want to mock
NUM_SESSIONS=15 
# How long each session should hold the streaming connection open (in seconds)
SESSION_DURATION=45 

echo "Starting session generator. Simulating $NUM_SESSIONS concurrent connections..."

for i in $(seq 1 $NUM_SESSIONS); do
  # Run an HTTP long-polling or streaming connection in the background
  curl -s -N -X POST \
    -d "LS_adapter_set=${ADAPTER_SET}&LS_cid=${CLIENT_ID}_$i" \
    "${TARGET_URL}?LS_protocol=${PROTOCOL}" > /dev/null &
done

# Keep script alive for the duration of the stream sessions
sleep $SESSION_DURATION

echo "Sessions expired. Cleaning up."
kill $(jobs -p) 2>/dev/null