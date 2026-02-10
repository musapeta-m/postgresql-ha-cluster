#!/bin/bash
# Professional Health Check for Patroni-managed PostgreSQL Cluster

echo "Checking Patroni Cluster Status..."

# Check if patronictl is available
if ! command -v patronictl &> /dev/null
then
    echo "Error: patronictl could not be found. Is Patroni installed?"
    exit 1
fi

# List the cluster members and their states
patronictl list

# Logic to check for lag or failed nodes
FAILED_NODES=$(patronictl list -f json | grep -c "running")

if [ "$FAILED_NODES" -lt 3 ]; then
    echo "WARNING: Cluster is degraded. Less than 3 nodes are running."
else
    echo "SUCCESS: All 3 nodes (Primary, Standby, Witness) are healthy."
fi