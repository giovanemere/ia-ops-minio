#!/bin/bash

# Wait for MinIO to be ready
sleep 15

# Configure MinIO client
mc alias set local http://localhost:9000 minioadmin minioadmin123

# Create buckets
mc mb local/techdocs-storage --ignore-existing
mc mb local/repositories-backup --ignore-existing
mc mb local/build-artifacts --ignore-existing
mc mb local/static-assets --ignore-existing

# Set policies
mc policy set public local/techdocs-storage
mc policy set public local/static-assets

echo "Buckets setup completed"
