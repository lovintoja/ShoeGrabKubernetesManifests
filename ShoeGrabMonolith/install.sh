#!/bin/bash

IMAGE_NAME="monolith-db"
SERVICE_FILE="monolith-db.service"

if [ ! -f "Dockerfile" ]; then
  echo "Error: Dockerfile not found in the current directory."
  exit 1
fi

if [ ! -f "$SERVICE_FILE" ]; then
  echo "Error: $SERVICE_FILE not found in the current directory."
  exit 1
fi

echo "Building Docker image..."
docker build -t "$IMAGE_NAME" .
if [ $? -ne 0 ]; then
  echo "Error: Docker image build failed."
  exit 1
fi

if ! command -v systemctl &> /dev/null; then
  echo "Warning: systemctl not found. Skipping service enablement."
  exit 0
fi


echo "Copying service file..."
sudo cp "$SERVICE_FILE" /etc/systemd/system/
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy service file."
  exit 1
fi

echo "Enabling and starting systemd service..."
sudo systemctl enable "$SERVICE_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable service."
  exit 1
fi

sudo systemctl start "$SERVICE_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to start service."
  exit 1
fi

echo "Monolith DB setup complete."