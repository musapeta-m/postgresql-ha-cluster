System Architecture: High-Availability PostgreSQL 17
1. Design Philosophy
The primary objective of this architecture is to provide a Self-Healing Database Cluster. By utilizing a distributed consensus model (Raft), the system removes the "Single Point of Failure" (SPOF) common in traditional primary-replica setups.

2. Topology Overview
The cluster follows a 3-node quorum model to ensure stability and data integrity:

Node		Component				Function						Data Storage
Node 1			Primary	Active 		R/W Traffic							Yes
Node 2			Sync Standby		Hot Standby (Failover Target)		Yes
Node 3			Witness				Tie-breaker for Consensus			No

3. Component Deep-Dive
A. Distributed Configuration Store (etcd)
We utilize etcd3 as the source of truth for the cluster state.

Leader Key: Patroni acquires a "Leader Key" in etcd with a defined TTL. If the primary node fails to heartbeat, the key expires.

Consensus: A majority (2 out of 3) must agree on the new leader before promotion occurs. This prevents Split-Brain scenarios.

B. Cluster Management (Patroni)
Patroni acts as a "Guardian" process for PostgreSQL. It handles:

Automatic initialization of standby nodes via pg_basebackup.

Re-syncing failed primaries using pg_rewind.

Managing synchronous replication states dynamically.

C. Data Integrity (Synchronous Commit)
To achieve an RPO of 0, we implement Synchronous Replication.

Logic: synchronous_commit = on.

Benefit: Transactions are not acknowledged to the application until the WAL is confirmed on the Synchronous Standby.

4. Failover Workflow
Detection: Primary node heartbeats to etcd stop.

Election: The Standby and Witness nodes recognize the leader key is gone.

Promotion: The Standby (having the most recent LSN) claims the leader key.

Reconfiguration: Patroni updates the PostgreSQL configuration to read-write mode.

Routing: Application traffic is redirected via HAProxy or a Floating IP (External to this repo).

5. Monitoring & Observability
Health is monitored via the Patroni REST API (Port 8008), which provides JSON-formatted cluster status for Prometheus/Grafana integration.