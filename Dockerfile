# ---- Dependencies (Install only once) ----
FROM node:alpine AS deps
WORKDIR /app
COPY package.json ./
RUN yarn install --frozen-lockfile

# ---- Build (uses deps) ----
FROM node:alpine AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN yarn build

# ---- Production runtime ----
FROM node:alpine AS runner
WORKDIR /app

# Only copy production node_modules
COPY --from=deps /app/node_modules ./node_modules

# Copy ONLY the output of the build, not the entire project
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY package.json ./

ENV NODE_ENV=production
EXPOSE 3000

# Next.js recommended command
CMD ["yarn", "start"]
