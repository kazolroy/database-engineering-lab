# PostgreSQL Database & Data Engineering Lab

Hands-on practical lab using PostgreSQL 17, Docker, and Python (psycopg) covering query performance tuning, bulk ETL ingestion, idempotent upserts, backup/restore, streaming replication, and failover promotion.

## Key Benchmarks & Lab Results

1. B-Tree Index Optimization (1,000,000 rows in transactions)
   - Query: SELECT * FROM transactions WHERE user_id = 25432;
   - Before Index (Seq Scan): 52.608 ms
   - After B-Tree Index (Index Scan): 0.197 ms (~267x faster)

2. Python ETL Ingestion & Idempotent Upsert
   - Loaded 50,000 rows into staging_transactions using psycopg COPY.
   - Aggregated and upserted into user_spend_summary using INSERT ... ON CONFLICT DO UPDATE.

3. Backup & Disaster Recovery
   - Logical backup and selective table recovery via pg_dump (-F c) and pg_restore.
   - Physical base backup via pg_basebackup.

4. Streaming Replication & Failover
   - Configured Primary (pg-lab) to Read Replica (pg-replica) streaming replication (pg_stat_replication in streaming state).
   - Simulated primary outage and promoted replica to read-write primary via pg_ctl promote (pg_is_in_recovery() transitioned from t to f).

## Repository Contents
- etl_load.py - Bulk CSV generation and COPY ingestion into PostgreSQL.
- lab_queries.sql - Schema, indexing, and idempotent upsert SQL scripts.
