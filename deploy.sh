#!/bin/bash
set -e

SERVER="root@217.182.195.6"
REMOTE_PATH="/var/www/skiprestriction.uk"

echo "Building site..."
hugo --gc --minify

echo "Deploying to $SERVER:$REMOTE_PATH..."
rsync -avz --delete public/ "$SERVER:$REMOTE_PATH/"

echo "Done! Site deployed to https://skiprestriction.uk"
