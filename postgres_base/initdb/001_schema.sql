CREATE SCHEMA IF NOT EXISTS store;

CREATE TABLE IF NOT EXISTS store.products (
  product   text NOT NULL,
  brand     text NOT NULL,
  price     numeric(12,2) NOT NULL,
  least_sp  numeric(12,2) NOT NULL
);

-- Seed only if table is empty (first boot will be empty anyway; this keeps it safe)
DO $$
BEGIN
  IF (SELECT COUNT(*) FROM store.products) = 0 THEN
    COPY store.products(product, brand, price, least_sp)
    FROM '/docker-entrypoint-initdb.d/data/electronics_products.csv'
    WITH (FORMAT csv, HEADER true);
  END IF;
END $$;
