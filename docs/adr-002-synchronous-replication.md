ADR 002: Implementation of Synchronous Replication
Status
Accepted

Context
In a high-availability PostgreSQL cluster, we must decide between Asynchronous (higher performance) and Synchronous (higher data integrity) replication. For this enterprise-grade architecture, the primary requirement is Zero Data Loss (RPO = 0) in the event of a primary node failure.

Decision
We have enabled synchronous_commit = on and configured synchronous_standby_names = '*'.

Consequences
Pros: > * Guarantees that the standby has received the WAL (Write Ahead Log) before the primary confirms success to the application.

Eliminates data loss during failover.

Cons: > * Increases "Write Latency" because the primary must wait for an acknowledgement (ACK) from the standby.

If the standby node fails, the primary will block writes until a new standby is available or timeout settings are reached.

Mitigation
To prevent the cluster from locking up if one node fails, we utilize a 3-node quorum. This ensures that even if the primary or a standby goes down, the Witness node maintains the cluster majority, allowing the DBA to promote a new standby quickly.