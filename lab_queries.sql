-- 1. Transactions table
CREATE TABLE IF NOT EXISTS transactions (
    tx_id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Single-column B-Tree index
CREATE INDEX IF NOT EXISTS idx_transactions_user_id
ON transactions(user_id);

-- 3. Composite index
CREATE INDEX IF NOT EXISTS idx_transactions_user_status_created
ON transactions (user_id, status, created_at DESC);

-- 4. Target summary table
CREATE TABLE IF NOT EXISTS user_spend_summary (
    user_id INT PRIMARY KEY,
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    tx_count INT NOT NULL DEFAULT 0,
    last_status VARCHAR(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Idempotent Upsert from staging_transactions
INSERT INTO user_spend_summary (user_id, total_amount, tx_count, last_status, updated_at)
SELECT
    user_id,
    SUM(amount),
    COUNT(*),
    MAX(status),
    NOW()
FROM staging_transactions
GROUP BY user_id
ON CONFLICT (user_id) DO UPDATE SET
    total_amount = user_spend_summary.total_amount + EXCLUDED.total_amount,
    tx_count = user_spend_summary.tx_count + EXCLUDED.tx_count,
    last_status = EXCLUDED.last_status,
    updated_at = NOW();
