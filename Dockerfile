# syntax=docker/dockerfile:1

# --- Stage 1: build the Vite production bundle ---
FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies from the lockfile for reproducible builds
COPY package.json package-lock.json ./
RUN npm ci

# Build the static assets into dist/
COPY . .
RUN npm run build

# --- Stage 2: serve the static bundle with Nginx ---
FROM nginx:alpine AS runtime

# Use the project's hardened Nginx configuration (serves /app, listens on 80)
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Ship only the compiled assets, nothing from the build toolchain
COPY --from=build /app/dist /app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
