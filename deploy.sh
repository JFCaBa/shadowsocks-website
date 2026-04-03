#!/bin/bash
set -e

SERVER="ubuntu@217.182.195.66"
REMOTE_PATH="/opt/shadowsocks-website"

echo "Deploying to $SERVER..."
ssh "$SERVER" << 'REMOTE'
set -e

# Clone or pull
if [ -d /opt/shadowsocks-website ]; then
  cd /opt/shadowsocks-website
  git pull
else
  git clone https://github.com/JFCaBa/shadowsocks-website.git /opt/shadowsocks-website
  cd /opt/shadowsocks-website
fi

# Install Hugo if not present
if ! command -v hugo &> /dev/null; then
  echo "Installing Hugo..."
  apt-get update && apt-get install -y hugo
fi

# Install Node.js dependencies
if [ ! -d node_modules ]; then
  npm install
fi

# Build
hugo --gc --minify

echo "Build complete. Site at /opt/shadowsocks-website/public/"
REMOTE

echo "Done! Site deployed to https://skiprestriction.uk"
