#!/bin/bash

# Store the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SERVICES_DIR="$PROJECT_ROOT/services"

# Loop through each directory in services/
for service_dir in "$SERVICES_DIR"/*; do
  if [ -d "$service_dir" ]; then
    echo "Starting service in: $(basename "$service_dir")"
    cd "$service_dir" || exit
    docker compose pull
    docker compose up -d
  fi
done

# Return to original directory
cd "$SCRIPT_DIR" || exit
