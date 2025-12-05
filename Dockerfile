# ---- Base image ----
FROM node:alpine AS base
WORKDIR /app
# ---- Dependencies ----
FROM base AS deps
COPY package.json ./
RUN yarn install --frozen-lockfile
# ---- Build ----
FROM base AS build
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN yarn build
# ---- Production ----
FROM node:alpine AS production
WORKDIR /app
COPY package.json ./
RUN yarn install --frozen-lockfile --production
COPY --from=build /app ./
EXPOSE 3000
CMD ["node", "dist/main.js"]
