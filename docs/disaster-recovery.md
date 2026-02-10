Disaster Recovery Strategy: PostgreSQL + pgbackrest
Overview
This document outlines the recovery procedures for the 3-node Patroni cluster. We utilize pgbackrest for its ability to handle multi-terabyte databases with high throughput and its native support for S3/Azure/GCS repositories.

Backup Architecture
Full Backups: Weekly (Sunday 00:00).

Differential Backups: Daily (00:00).

WAL Archiving: Continuous. Every Write-Ahead Log (WAL) is pushed to the repository immediately via archive_command.

Recovery Objectives (RPO/RTO)
Recovery Point Objective (RPO): < 5 minutes (Near-zero data loss).

Recovery Time Objective (RTO): < 30 minutes for a 100GB database via Delta Restore.

Scenario											Action									Tool
Primary Node Hardware Failure			Automatic Failover to Synchronous Standby			Patroni
Total Cluster Loss / Data Corruption	Point-in-Time Recovery (PITR)						pgbackrest
Accidental Table Drop					Restore to specific timestamp before the drop		pgbackrest