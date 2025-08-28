# ETAPA 1: Construcción (Builder)
# Instala todo y compila el código de TypeScript a JavaScript.
FROM node:21-alpine3.18 as builder

RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

COPY package*.json pnpm-lock.yaml ./
RUN pnpm install

COPY . .
# ✅ SE AÑADE EL PASO DE COMPILACIÓN
RUN pnpm run build


# ETAPA 2: Producción (Deploy)
# Crea la imagen final, más ligera y optimizada.
FROM node:21-alpine3.18 as deploy

RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# Copia solo lo necesario desde la etapa de construcción
COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./
# ✅ SE COPIA LA CARPETA 'dist' (CÓDIGO COMPILADO)
COPY --from=builder /app/dist ./dist

# Instala solo las dependencias de PRODUCCIÓN
RUN pnpm install --frozen-lockfile --production

# Comando para iniciar la aplicación
CMD ["npm", "start"]
