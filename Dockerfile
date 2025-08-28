FROM node:20-slim

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo
WORKDIR /usr/src/app

# Copia los archivos de la carpeta app
COPY ./app/package*.json ./

# Instala dependencias con npm (más estable)
RUN npm ci || npm install

# Copia el resto del código de la carpeta app
COPY ./app .

# Compila el proyecto
RUN npm run build

# Expone el puerto
EXPOSE 3008

# Comando para iniciar
CMD ["npm", "start"]
