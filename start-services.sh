#!/bin/bash
set -e

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to generate connection strings and save them to a file
generate_connection_strings() {
  echo "Generating connection strings..."

  # Get server information from config
  SERVER_ADDRESS="test.aaa.com"
  SERVER_PORT="80"
  VMESS_UUID=$(grep -o '"id": "[^"]*"' "$SCRIPT_DIR/Xray/config.json" | head -1 | cut -d '"' -f 4)
  VMESS_PATH=$(grep -o '"path": "[^"]*"' "$SCRIPT_DIR/Xray/config.json" | head -1 | cut -d '"' -f 4)
  VLESS_PATH=$(grep -o '"path": "[^"]*"' "$SCRIPT_DIR/Xray/config.json" | tail -1 | cut -d '"' -f 4)

  # Create VMess JSON config
  VMESS_JSON='{"v":"2","ps":"Xray VMess Connection","add":"'$SERVER_ADDRESS'","port":"'$SERVER_PORT'","id":"'$VMESS_UUID'","aid":"0","net":"ws","type":"none","host":"'$SERVER_ADDRESS'","path":"'$VMESS_PATH'","tls":"","sni":"'$SERVER_ADDRESS'","alpn":"","fp":"","allowInsecure":true,"security":"auto"}'

  # Encode VMess config to base64
  VMESS_LINK="vmess://$(echo -n "$VMESS_JSON" | base64 -w 0)"

  # Create VLESS link
  # Check if jq is installed
  if command -v jq &> /dev/null; then
    ENCODED_PATH=$(echo -n "$VLESS_PATH" | jq -sRr @uri)
  else
    # Simple URL encoding for path if jq is not available
    ENCODED_PATH=$(echo -n "$VLESS_PATH" | sed 's/\//%2F/g')
  fi
  VLESS_LINK="vless://$VMESS_UUID@$SERVER_ADDRESS:$SERVER_PORT?encryption=none&security=none&type=ws&host=$SERVER_ADDRESS&sni=$SERVER_ADDRESS&path=$ENCODED_PATH#Xray_VLESS_Connection"

  # Save to file
  CONNECTION_FILE="$SCRIPT_DIR/xray_connections.txt"
  echo "# Xray Connection Strings - Generated on $(date)" > "$CONNECTION_FILE"
  echo "" >> "$CONNECTION_FILE"
  echo "## VMess Connection" >> "$CONNECTION_FILE"
  echo "$VMESS_LINK" >> "$CONNECTION_FILE"
  echo "" >> "$CONNECTION_FILE"
  echo "## VLESS Connection" >> "$CONNECTION_FILE"
  echo "$VLESS_LINK" >> "$CONNECTION_FILE"

  echo "Connection strings saved to: $SCRIPT_DIR/xray_connections.txt"
}

# Start Xray in the background
echo "Starting Xray..."
cd "$SCRIPT_DIR/Xray"

# Create log directories if they don't exist
mkdir -p logs

# Start Xray
./xray run -c config.json &
XRAY_PID=$!

# Save Xray PID
echo $XRAY_PID > "$SCRIPT_DIR/Xray/xray.pid"

# Health check for Xray
sleep 2 # Give Xray a moment to initialize
echo "Performing Xray health check..."
HEALTH_CHECK_ATTEMPTS=5
HEALTH_CHECK_SUCCESS=false
for i in $(seq 1 $HEALTH_CHECK_ATTEMPTS); do
  if nc -z 127.0.0.1 10000; then # Check VMess port
    echo "Xray health check successful on port 10000."
    HEALTH_CHECK_SUCCESS=true
    break
  fi
  echo "Attempt $i of $HEALTH_CHECK_ATTEMPTS: Xray not yet responding on port 10000. Retrying in 1 second..."
  sleep 1
done

if [ "$HEALTH_CHECK_SUCCESS" = false ]; then
  echo "Failed to confirm Xray is listening on port 10000 after $HEALTH_CHECK_ATTEMPTS attempts."
  echo "Please check Xray logs: $SCRIPT_DIR/Xray/logs/error.log"
  # Optionally, kill Xray if it started but is unhealthy
  # kill $XRAY_PID
  # rm -f "$SCRIPT_DIR/Xray/xray.pid" # Clean up PID file if you kill it
  exit 1
fi

echo "Xray started with PID: $XRAY_PID"

# Generate and save connection strings
generate_connection_strings

# Give Xray a moment to start
sleep 2

# Start Nginx
echo "Starting Nginx..."
cd "$SCRIPT_DIR/Nginx"
chmod +x start-nginx.sh
./start-nginx.sh

# Wait for Nginx to exit
wait

# If Nginx exits, kill Xray
kill $XRAY_PID
