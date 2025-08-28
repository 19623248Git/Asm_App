#!/bin/bash

# Start Nginx in the background.
# The '-g "daemon off;"' is crucial for running Nginx correctly in a Docker container.
echo "Starting Nginx..."
nginx -g "daemon off;" &

# Start your custom assembly server in the foreground using the Makefile.
# This will be the main process that keeps the container running.
echo "Starting custom assembly server..."
make run