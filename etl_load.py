import csv
import io
import psycopg


def generate_and_load_csv(rows_count: int = 50000):
    buffer = io.StringIO()
    writer = csv.writer(buffer)

    for i in range(1, rows_count + 1):
        user_id = (i % 50000) + 1
        amount = round((i * 13.75) % 9500 + 10, 2)
        status = "COMPLETED" if i % 5 != 0 else "PENDING"
        writer.writerow([user_id, amount, status])

    buffer.seek(0)

    conninfo = "host=localhost port=5432 dbname=ecommerce_db user=admin password=secretpass"
    with psycopg.connect(conninfo) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS staging_transactions (
                    stage_id BIGSERIAL PRIMARY KEY,
                    user_id INT NOT NULL,
                    amount NUMERIC(10, 2) NOT NULL,
                    status VARCHAR(20) NOT NULL,
                    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """)
            with cur.copy(
                "COPY staging_transactions (user_id, amount, status) FROM STDIN WITH (FORMAT CSV)"
            ) as copy:
                copy.write(buffer.getvalue())
        conn.commit()
    print(f"Loaded {rows_count} rows into staging_transactions successfully.")


if __name__ == "__main__":
    generate_and_load_csv(50000)
