# ETAPA 1: Construcción (Builder)
FROM node:21-alpine3.18 as builder

RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# --- LÍNEA CLAVE AÑADIDA ---
# Instalar 'git', que es necesario para algunas dependencias del proyecto
RUN apk add --no-cache git

COPY package*.json pnpm-lock.yaml ./
# Ahora pnpm install podrá usar git para descargar dependencias
RUN pnpm install

COPY . .
RUN pnpm run build


# ETAPA 2: Producción (Deploy)
# Esta etapa no necesita cambios
FROM node:21-alpine3.18 as deploy

RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./
COPY --from=builder /app/dist ./dist

RUN pnpm install --frozen-lockfile --production

CMD ["npm", "start"]
