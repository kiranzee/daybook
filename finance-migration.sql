CREATE TABLE IF NOT EXISTS income_transactions (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  source VARCHAR(160) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  currency CHAR(3) NOT NULL,
  income_date DATE NOT NULL,
  note VARCHAR(500) NULL,
  migration_key VARCHAR(80) NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_income_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_income_user_date (user_id, income_date DESC),
  CHECK (amount > 0)
);

CREATE TABLE IF NOT EXISTS budget_limits (
  user_id CHAR(36) NOT NULL,
  currency CHAR(3) NOT NULL,
  monthly_limit DECIMAL(14,2) NOT NULL DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, currency),
  CONSTRAINT fk_budget_limits_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CHECK (monthly_limit >= 0)
);

INSERT IGNORE INTO income_transactions
  (id,user_id,source,amount,currency,income_date,note,migration_key)
SELECT UUID(),id,'Opening balance',monthly_budget,currency,CURDATE(),
       'Migrated from legacy monthly budget',CONCAT('legacy-opening-',id)
FROM users
WHERE monthly_budget > 0;
