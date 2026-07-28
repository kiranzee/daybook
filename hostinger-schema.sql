-- Import this file into the database created in Hostinger hPanel.
-- Select the target database in phpMyAdmin before importing.

CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NULL,
  currency CHAR(3) NOT NULL DEFAULT 'GBP',
  monthly_budget DECIMAL(14,2) NOT NULL DEFAULT 2500.00,
  color CHAR(7) NOT NULL DEFAULT '#1d654f',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (monthly_budget >= 0)
);

CREATE TABLE IF NOT EXISTS sessions (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_sessions_token_expiry (token_hash, expires_at)
);

CREATE TABLE IF NOT EXISTS expenses (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  merchant VARCHAR(160) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  currency CHAR(3) NOT NULL,
  category VARCHAR(40) NOT NULL,
  expense_date DATE NOT NULL,
  note VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_expenses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_expenses_user_date (user_id, expense_date DESC),
  CHECK (amount > 0)
);

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

INSERT IGNORE INTO users (id, name, email, currency, monthly_budget, color) VALUES
('11111111-1111-4111-8111-111111111111', 'Neera Patel', 'neera@example.com', 'GBP', 2200, '#1d654f'),
('22222222-2222-4222-8222-222222222222', 'Arjun Patel', 'arjun@example.com', 'USD', 3000, '#735f92');

INSERT IGNORE INTO income_transactions
  (id,user_id,source,amount,currency,income_date,note,migration_key)
SELECT UUID(),id,'Opening balance',monthly_budget,currency,CURDATE(),
       'Migrated from legacy monthly budget',CONCAT('legacy-opening-',id)
FROM users WHERE monthly_budget > 0;
