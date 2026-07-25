FROM node:22-alpine

ENV NODE_ENV=production
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY index.html app.js styles.css server.js ./
COPY assets ./assets

RUN chown -R node:node /app
USER node

EXPOSE 3000
CMD ["node", "server.js"]
