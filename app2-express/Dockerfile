FROM node:20-alpine

WORKDIR /app
RUN addgroup -S app && adduser -S app -G app

COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD wget -qO- http://localhost:3000/health || exit 1

USER app

CMD ["npm", "start"]
