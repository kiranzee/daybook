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

INSERT IGNORE INTO users (id, name, email, currency, monthly_budget, color) VALUES
('11111111-1111-4111-8111-111111111111', 'Neera Patel', 'neera@example.com', 'GBP', 2200, '#1d654f'),
('22222222-2222-4222-8222-222222222222', 'Arjun Patel', 'arjun@example.com', 'USD', 3000, '#735f92');
