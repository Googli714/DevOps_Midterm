#!/bin/bash

# Monitoring Setup Script
# Usage: ./setup_monitoring.sh

# Configuration
LOG_DIR="${PROJECT_ROOT}/logs"
INTERVAL="60"  # Default check interval in seconds
LOG_FILE="$LOG_DIR/LOGS.txt"

notify-send ${LOG_FILE}
# Ensure log directory exists
mkdir -p $LOG_DIR

# Log function
log() {
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $1" | tee -a $LOG_FILE
}

log "Starting health check service (interval: ${INTERVAL}s)"

# Continuous health check
while true; do
  # Get current time
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")

  # Perform health check
  response=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")

  if [ "$response" = "200" ]; then
    status="HEALTHY"
  else
    status="UNHEALTHY (HTTP $response)"
  fi

  # Log the result
  log "Status: $status"

  # Sleep for the specified interval
  sleep $INTERVAL
done