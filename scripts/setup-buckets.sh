#!/bin/bash

# Wait for MinIO to be ready
sleep 15

# Configure MinIO client
mc alias set local http://localhost:9000 minioadmin minioadmin123

# Create buckets
mc mb local/iaops-portal --ignore-existing
mc mb local/repositories-backup --ignore-existing
mc mb local/build-artifacts --ignore-existing
mc mb local/static-assets --ignore-existing

# Set policies (using correct command)
mc anonymous set public local/iaops-portal
mc anonymous set public local/static-assets

echo "Buckets setup completed"
