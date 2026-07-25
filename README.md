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

Open `http://localhost:3000`.

## Features

- Separate expenses, budget, and preferred currency per user
- Expense entry in GBP, USD, EUR, INR, JPY, CAD, AUD, and GEL
- Converted totals with original currency retained
- Daily spending chart, category breakdown, filters, and responsive mobile layout
- MySQL persistence through a validated Express REST API
- Indexed per-user expense history with cascading profile deletion

Exchange rates are bundled demo rates relative to GBP. A production deployment should replace them with a versioned exchange-rate API and add authentication/authorization before exposing the service publicly.
