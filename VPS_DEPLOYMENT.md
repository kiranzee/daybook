# Hostinger VPS deployment with Docker

## 1. Point your domain to the VPS

Create an `A` record for your chosen hostname, such as `expenses.example.com`,
pointing to the VPS public IPv4 address. Wait for DNS to resolve before starting
Caddy so it can issue an HTTPS certificate.

## 2. Upload the application

Upload and extract `daybook-vps.zip` on the VPS, then enter its directory:

```bash
unzip daybook-vps.zip -d daybook
cd daybook
```

## 3. Configure secrets

```bash
cp .env.production.example .env.production
nano .env.production
```

Set the real domain and your existing MySQL server's host, port, database,
username, password, and a long random `REGISTRATION_CODE`. Household members
need this private code only when creating or claiming an account. Never commit
or share `.env.production`.

Your MySQL server must allow connections from the VPS public IP. If MySQL runs
directly on the same VPS host rather than inside this Compose network, use the
host's reachable private/public IP or `host.docker.internal` when supported;
`localhost` inside the app container points to the container itself.

For an existing Daybook database, apply the authentication migration once:

```bash
mysql -h "$DB_HOST" -u "$DB_USER" -p "$DB_NAME" < auth-migration.sql
```

Existing profiles keep their expenses. On the registration screen, use the
same email address plus the private registration code to claim the profile and
set its first password.

## 4. Start the stack

```bash
docker compose --env-file .env.production up -d --build
docker compose --env-file .env.production ps
```

The stack contains:

- `app`: the Node.js/Express application
- `caddy`: reverse proxy with automatic HTTPS

The stack does not create or manage MySQL. Your existing database must already
contain the `users` and `expenses` tables. If needed, import
`hostinger-schema.sql` into that database once.

## 5. Verify

```bash
docker compose --env-file .env.production logs --tail=100
curl https://YOUR_DOMAIN/api/health
```

Expected health response:

```json
{"status":"ok","database":"connected"}
```

## Updates

Upload the changed project files and run:

```bash
docker compose --env-file .env.production up -d --build
```

Database backups remain the responsibility of your external MySQL service.
Keep `.env.production` private.
