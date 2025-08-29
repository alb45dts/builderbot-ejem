FROM node:20-slim

# Herramientas necesarias y pnpm estable
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates python3 make g++ \
    && npm install -g pnpm@9.1.0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Copia solo package.json para cachear dependencias
COPY package.json ./

# Instala dependencias (si no hay lock, pnpm lo generará)
RUN pnpm install

# Copia el resto del código
COPY . .

# Compila
RUN pnpm run build

EXPOSE 3008

CMD ["pnpm", "start"]
