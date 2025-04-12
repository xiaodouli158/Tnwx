# Client Configuration Guide

This guide provides instructions for configuring your client to connect to the Xray server using VMess or VLESS protocols over WebSocket with TLS (HTTPS).

## Server Information

- Server Address: `8c92ts-8080.csb.app`
- Port: `8443`
- TLS: `Enabled`

## VMess Configuration

### Configuration Parameters

- Protocol: `VMess`
- Server Address: `8c92ts-8080.csb.app`
- Port: `8443`
- UUID: `de04add9-5c68-8bab-950c-08cd5320df18`
- AlterID: `0`
- Security: `auto`
- Network: `WebSocket (ws)`
- WebSocket Path: `/api/stream/data`
- TLS: `Enabled`

### Example Configuration (V2Ray/Xray Format)

```json
{
  "outbounds": [
    {
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "8c92ts-8080.csb.app",
            "port": 8443,
            "users": [
              {
                "id": "de04add9-5c68-8bab-950c-08cd5320df18",
                "alterId": 0,
                "security": "auto"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "/api/stream/data"
        }
      }
    }
  ]
}
```

## VLESS Configuration

### Configuration Parameters

- Protocol: `VLESS`
- Server Address: `8c92ts-8080.csb.app`
- Port: `8443`
- UUID: `de04add9-5c68-8bab-950c-08cd5320df18`
- Flow: (leave empty)
- Encryption: `none`
- Network: `WebSocket (ws)`
- WebSocket Path: `/api/events/subscribe`
- TLS: `Enabled`

### Example Configuration (V2Ray/Xray Format)

```json
{
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "8c92ts-8080.csb.app",
            "port": 8443,
            "users": [
              {
                "id": "de04add9-5c68-8bab-950c-08cd5320df18",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "/api/events/subscribe"
        }
      }
    }
  ]
}
```

## Testing the Connection

1. Configure your client using one of the methods above
2. Connect to the server
3. Test the connection by visiting a website or using a service like `curl ifconfig.me` to verify your IP address has changed

## Troubleshooting

If you encounter connection issues:

1. Verify that all configuration parameters are correct
2. Ensure that your client supports WebSocket over TLS
3. Check that the server is running and accessible
4. If using a self-signed certificate, you may need to disable certificate verification in your client
