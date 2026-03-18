FROM node:20-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS builder
WORKDIR /app
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm build --filter web

FROM base AS runner
WORKDIR /app
COPY --from=builder /app/clients/app-client/apps/web/dist ./dist
COPY --from=builder /app/clients/app-client/apps/web/package.json .
# We need node_modules for server dependencies (express, etc)
# In a perfect world we use pnpm deploy --filter web --prod /prod/web
# But for now, let's copy the monorepo node_modules or install prod deps
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/clients/app-client/node_modules ./clients/app-client/node_modules

EXPOSE 3000
CMD ["node", "dist/server/index.js"]