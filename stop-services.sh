#!/bin/bash

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
if pgrep -f "xray" > /dev/null; then
  echo "Stopping Xray..."
  pkill -f "xray"
  echo "Xray stopped"
else
  echo "Xray is not running"
fi

echo "All services stopped"
