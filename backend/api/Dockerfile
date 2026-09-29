# PetPaws API image — used by docker-compose.e2e.yml for the Jenkins E2E stage
# and by the Lab 07 Build Image / Container Scan / Blue-Green Deploy stages.
#
# Multi-stage: npm is only needed to build. The runtime stage drops it (and yarn),
# because the copies bundled with node:24-alpine carry HIGH CVEs that Trivy blocks on
# (brace-expansion, ip-address, tar) and the app never calls npm at runtime.

FROM node:24-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build && npm prune --omit=dev

FROM node:24-alpine
RUN apk upgrade --no-cache \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx \
              /opt/yarn* /usr/local/bin/yarn /usr/local/bin/yarnpkg
WORKDIR /app

COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "dist/main.js"]
