# High-Availability PostgreSQL 17 Cluster with Patroni & etcd

## 📌 Project Overview
This repository contains the architectural design and configuration for a production-grade **PostgreSQL 17** High-Availability (HA) cluster. The system is designed to provide **Zero Data Loss (RPO=0)** and **Automatic Failover (RTO < 30s)** using a distributed consensus model.



## 🏗️ The Architecture
The cluster utilizes a 3-node quorum to maintain data integrity and prevent "Split-Brain" scenarios:

1.  **Primary Node:** Handles all Read/Write operations.
2.  **Synchronous Standby:** Maintains a real-time copy of the data. Configured with `synchronous_commit` to ensure data durability.
3.  **Witness Node:** A lightweight node that does not store data but participates in the **etcd** consensus to ensure a majority vote during leader elections.

### Tech Stack
* **Database:** PostgreSQL 17
* **Cluster Management:** Patroni
* **Consensus Store:** etcd (3-node cluster)
* **Backup & Recovery:** pgbackrest
* **Infrastructure:** Linux (Ubuntu/RHEL)

---

## 📁 Project Structure

* [**/configs**](./configs): Optimized templates for `patroni.yml`, `etcd.conf`, and `postgresql.conf`.
* [**/docs**](./docs): Architectural Decision Records (ADRs) and the [Disaster Recovery Plan](./docs/disaster-recovery.md).
* [**/scripts**](./scripts): Automation tools for [Health Checks](./scripts/health-check.sh) and manual failover testing.

---

## 🚀 Key Features

### 1. Automated Failover & Leader Election
Using **Patroni**, the cluster monitors the health of the primary node. If the primary becomes unresponsive, **etcd** facilitates a leader election, and the standby is promoted automatically without manual intervention.

### 2. High-Integrity Replication

We have implemented **Synchronous Replication** to guarantee that no transaction is confirmed to the application until it has been safely written to at least one standby node.

### 3. Advanced Disaster Recovery
Backups are managed via **pgbackrest**, supporting:
* Full, Differential, and Incremental backups.
* **Point-in-Time Recovery (PITR)** to any specific microsecond.
* **Delta Restore** to minimize recovery time during hardware failures.

---

## 🛠️ Deployment & Testing
To validate this architecture, I performed the following "Day 2" operations:
1.  **Simulated Network Partition:** Verified that the Witness node successfully breaks ties during a split-brain event.
2.  **PITR Validation:** Performed a successful restore of a "dropped" table using pgbackrest WAL archives.
3.  **Switchover Test:** Used `patronictl switchover` to move the primary role between nodes with zero data loss.

---

## 🤝 Contact
**[Your Name]** *Data Architect / Database Administrator* [Your LinkedIn Profile Link] | [Your Professional Email]