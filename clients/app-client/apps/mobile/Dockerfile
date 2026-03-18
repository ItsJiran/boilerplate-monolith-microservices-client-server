FROM node:20-alpine
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app
COPY clients/app-client/apps/mobile/package.json ./package.json

# You likely need to copy the whole repo for monorepo workspace support
# But for simplicity, we focus on the app
RUN pnpm install

# For Mobile Build, assume web export
RUN pnpm build:web 

# Serve static web files
FROM nginx:alpine
COPY --from=0 /app/web-build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]