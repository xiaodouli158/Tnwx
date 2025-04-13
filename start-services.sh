#!/bin/bash

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to generate connection strings and save them to a file
generate_connection_strings() {
  echo "Generating connection strings..."

  # Get server information from config
  SERVER_ADDRESS="test.aaa.com"
  SERVER_PORT="443"
  VMESS_UUID=$(grep -o '"id": "[^"]*"' "$SCRIPT_DIR/Xray/config.json" | head -1 | cut -d '"' -f 4)
  VMESS_PATH=$(grep -o '"path": "[^"]*"' "$SCRIPT_DIR/Xray/config.json" | head -1 | cut -d '"' -f 4)
  VLESS_PATH=$(grep -o '"path": "[^"]*"' "$SCRIPT_DIR/Xray/config.json" | tail -1 | cut -d '"' -f 4)

  # Create VMess JSON config
  VMESS_JSON='{"v":"2","ps":"Xray VMess Connection","add":"'$SERVER_ADDRESS'","port":"'$SERVER_PORT'","id":"'$VMESS_UUID'","aid":"0","net":"ws","type":"none","host":"'$SERVER_ADDRESS'","path":"'$VMESS_PATH'","tls":"tls","sni":"'$SERVER_ADDRESS'","alpn":"","fp":"","allowInsecure":false,"security":"auto"}'

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
  VLESS_LINK="vless://$VMESS_UUID@$SERVER_ADDRESS:$SERVER_PORT?encryption=none&security=tls&type=ws&host=$SERVER_ADDRESS&sni=$SERVER_ADDRESS&path=$ENCODED_PATH#Xray_VLESS_Connection"

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

# Check if Xray started successfully
sleep 2
if ps -p $XRAY_PID > /dev/null; then
  echo "Xray started with PID: $XRAY_PID"
else
  echo "Failed to start Xray. Check logs for details."
  exit 1
fi

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
