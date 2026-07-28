# Daybook

A responsive day-to-day expense tracker with multiple user profiles, multi-currency conversion, and MySQL persistence.

## Run locally

1. Create the database and tables:

```powershell
mysql -u root -p < schema.sql
```

2. Copy `.env.example` to `.env` and set your MySQL credentials.

3. Install and run:

```powershell
npm install
npm start
```

## Authentication

Every household member signs in with their own email and password. Set a long,
private `REGISTRATION_CODE` in the environment before starting the app. New
accounts—and existing profiles being claimed for the first time—must provide
that code. Apply `auth-migration.sql` before deploying this version over an
existing database.

## Multi-currency ledger

Income and expenses are stored in their original currencies. Balances roll
forward indefinitely and are calculated separately for each currency; amounts
are never combined through an exchange rate. Optional monthly spending limits
are also maintained per currency.

Before deploying this feature over an existing database, apply
`finance-migration.sql` once. It converts each user's legacy monthly budget
into an opening-balance income transaction without duplicating it on reruns.

Open `http://localhost:3000`.

## Features

- Separate expenses, budget, and preferred currency per user
- Expense entry in GBP, USD, EUR, INR, JPY, CAD, AUD, and GEL
- Converted totals with original currency retained
- Daily spending chart, category breakdown, filters, and responsive mobile layout
- MySQL persistence through a validated Express REST API
- Indexed per-user expense history with cascading profile deletion

Exchange rates are bundled demo rates relative to GBP. A production deployment should replace them with a versioned exchange-rate API and add authentication/authorization before exposing the service publicly.
