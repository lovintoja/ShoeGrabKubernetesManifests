#!/bin/bash

statefulsets=("postgres-db1" "postgres-db2" "postgres-db3" "postgres-db4")
secret_file="postgres-credentials.yaml"

apply_resource() {
  local resource_type="$1"
  local name="$2"
  local manifest_file="$3"

  if [ ! -f "$manifest_file" ]; then
    echo "Error: Manifest file '$manifest_file' not found."
    return 1
  fi

  echo "Applying/replacing $resource_type: $name"

  kubectl apply -f "$manifest_file"
  if [ $? -eq 0 ]; then
    echo "$resource_type $name applied successfully."
    return 0
  fi

  echo "Applying failed. Attempting to replace $resource_type: $name"
  kubectl replace --force -f "$manifest_file"
  if [ $? -eq 0 ]; then
    echo "$resource_type $name replaced successfully."
    return 0
  else
    echo "Error: Failed to replace $resource_type: $name"
    return 1
  fi
}

echo "Managing Secret: postgres-credentials"
if ! apply_resource "Secret" "postgres-credentials" "$secret_file"; then
  echo "Error: Failed to manage Secret. Exiting."
  exit 1
fi

for statefulset in "${statefulsets[@]}"; do
  if ! apply_resource "StatefulSet" "$statefulset" "${statefulset}.yaml"; then
    echo "Error: Failed to manage StatefulSet: $statefulset. Exiting."
    exit 1
  fi
done

echo "Kubernetes resource management complete."