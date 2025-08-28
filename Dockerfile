# ETAPA 1: Construcción (Builder)
FROM node:21-alpine3.18 as builder

RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# Instalar 'git'
RUN apk add --no-cache git

COPY package*.json pnpm-lock.yaml ./
RUN pnpm install

COPY . .
RUN pnpm run build


# ETAPA 2: Producción (Deploy)
FROM node:21-alpine3.18 as deploy

RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./
COPY --from=builder /app/dist ./dist

# ✅ SE CORRIGE EL COMANDO DE INSTALACIÓN FINAL
RUN pnpm install --prod

CMD ["npm", "start"]
