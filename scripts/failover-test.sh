#!/bin/bash
# ==========================================================
# Patroni Cluster Failover & Resilience Test
# ==========================================================
# Purpose: This script simulates a primary node failure to 
# validate automatic promotion and cluster quorum.

CLUSTER_NAME="postgres_ha_prod"
PRIMARY_NODE=$(patronictl -c /etc/patroni/patroni.yml list | grep "Leader" | awk '{print $2}')

echo "--- STARTING FAILOVER TEST FOR CLUSTER: $CLUSTER_NAME ---"
echo "Current Leader identified as: $PRIMARY_NODE"

# 1. Verification of Health before test
echo "[1/4] Verifying cluster health..."
patronictl list

# 2. Simulate Failure
# Choice: We use 'switchover' for a clean test or 'pause/stop' for a hard failure.
echo "[2/4] Initiating controlled switchover (planned failover)..."
# Using --force and --non-interactive for automation demonstration
patronictl switchover $CLUSTER_NAME --member $PRIMARY_NODE --force

# 3. Monitor Promotion
echo "[3/4] Waiting 15 seconds for leader election and promotion..."
sleep 15

# 4. Final Validation
echo "[4/4] Verifying new cluster state..."
patronictl list

NEW_LEADER=$(patronictl list | grep "Leader" | awk '{print $2}')

if [ "$PRIMARY_NODE" == "$NEW_LEADER" ]; then
    echo "RESULT: FAILOVER FAILED. $PRIMARY_NODE is still the leader."
    exit 1
else
    echo "RESULT: SUCCESS. $NEW_LEADER has been promoted to Leader."
fi

echo "--- TEST COMPLETE ---"