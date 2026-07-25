# Hostinger deployment

## Requirements

- Business Web Hosting or a Cloud plan with Node.js Web Apps
- Node.js 20 or newer
- A MySQL database created in hPanel

## Database

1. In hPanel, open **Websites → Dashboard → Database Management**.
2. Create a database and database user.
3. Open phpMyAdmin for that database.
4. Import `hostinger-schema.sql`.

## Node.js application

1. In hPanel, select **Websites → Add website → Node.js Web App**.
2. Upload `daybook-hostinger.zip`, or connect the project through GitHub.
3. Choose **Express.js**, Node.js **20.x or 22.x**, and `server.js` as the entry file.
4. Use `npm start` as the start command. No build command is required.
5. Add these environment variables in hPanel:

```text
NODE_ENV=production
DB_HOST=<hostname shown by Hostinger>
DB_PORT=3306
DB_USER=<Hostinger database user>
DB_PASSWORD=<Hostinger database password>
DB_NAME=<Hostinger database name>
DB_POOL_SIZE=10
```

Do not set `PORT` unless hPanel specifically asks for it; Hostinger supplies the application port.

## Verification

After deployment, open:

```text
https://your-domain.example/api/health
```

The expected response is:

```json
{"status":"ok","database":"connected"}
```
