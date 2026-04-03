#!/bin/bash

# Renews Tailscale TLS certificates and stores them in a shared location
# so multiple services (e.g. glances) can use them.
# Intended to be run periodically via launchd (every 90 days).

DOMAIN="miniserver.sphynx-ule.ts.net"
CERTS_DIR="/Users/miniserver/.local/share/certs"

mkdir -p "$CERTS_DIR"

/usr/local/bin/tailscale cert \
  --cert-file "$CERTS_DIR/$DOMAIN.crt" \
  --key-file "$CERTS_DIR/$DOMAIN.key" \
  "$DOMAIN"

# Convert to PKCS#12 format
openssl pkcs12 -export \
  -out "$CERTS_DIR/$DOMAIN.p12" \
  -inkey "$CERTS_DIR/$DOMAIN.key" \
  -in "$CERTS_DIR/$DOMAIN.crt" \
  -passout pass:
