#!/bin/bash
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Stopping services..."

# Stop Nginx if running
if pgrep -f "nginx" > /dev/null; then
  echo "Stopping Nginx..."
  if [ -f "$SCRIPT_DIR/Nginx/logs/nginx.pid" ]; then
    nginx_pid=$(cat "$SCRIPT_DIR/Nginx/logs/nginx.pid")
    kill $nginx_pid
    echo "Nginx stopped (PID: $nginx_pid)"
  else
    pkill -f nginx
    echo "Nginx stopped (using pkill)"
  fi
else
  echo "Nginx is not running"
fi

# Stop Xray if running
echo "Stopping Xray..."
XRAY_PID_FILE="$SCRIPT_DIR/Xray/xray.pid"
if [ -f "$XRAY_PID_FILE" ]; then
  XRAY_PID=$(cat "$XRAY_PID_FILE")
  if ps -p $XRAY_PID > /dev/null; then
    echo "Attempting to stop Xray (PID: $XRAY_PID) from PID file..."
    kill $XRAY_PID
    sleep 2 # Wait for graceful shutdown
    if ps -p $XRAY_PID > /dev/null; then
      echo "Xray (PID: $XRAY_PID) did not stop gracefully, sending SIGKILL..."
      kill -9 $XRAY_PID
      sleep 1
    fi
    if ps -p $XRAY_PID > /dev/null; then
        echo "Failed to stop Xray (PID: $XRAY_PID) even with SIGKILL."
    else
        echo "Xray stopped (PID: $XRAY_PID)"
        rm -f "$XRAY_PID_FILE"
    fi
  else
    echo "Xray process with PID $XRAY_PID (from PID file) not found. Cleaning up stale PID file."
    rm -f "$XRAY_PID_FILE"
    # Fallback to pkill just in case Xray is running under a different PID
    if pgrep -f "xray" > /dev/null; then
      echo "Attempting to stop Xray using pkill as a fallback..."
      pkill -f "xray"
      echo "Xray stopped (using pkill)"
    else
      echo "Xray is not running (checked after stale PID file removal)."
    fi
  fi
else
  echo "Xray PID file ($XRAY_PID_FILE) not found."
  if pgrep -f "xray" > /dev/null; then
    echo "Attempting to stop Xray using pkill..."
    pkill -f "xray"
    # Add a small delay and check if pkill was successful
    sleep 1
    if pgrep -f "xray" > /dev/null; then
        echo "pkill command issued, but Xray process still found. Manual check may be required."
    else
        echo "Xray stopped (using pkill)"
    fi
  else
    echo "Xray is not running (checked by pgrep)."
  fi
fi

echo "All services stopped"
