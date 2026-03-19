// server/index.ts
import express from 'express';
import compression from 'compression';
import cookieParser from 'cookie-parser';
import { renderPage } from 'vike/server';
import { dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = `${__dirname}/..`;

const isProduction = process.env.NODE_ENV === 'production';

function normalizeRequestHeaders(headers: Record<string, string | string[] | undefined>) {
  return Object.fromEntries(
    Object.entries(headers).map(([key, value]) => [
      key.toLowerCase(),
      Array.isArray(value) ? value.join('; ') : value,
    ])
  );
}

async function startServer() {
  const app = express();

  app.use(compression());
  app.use(cookieParser());

  // Vite integration
  if (isProduction) {
    app.use(express.static(`${root}/dist/client`));
  } else {
    // Instantiate Vite's development server and integrate its middleware to our server.
    const vite = await import('vite').then(m => m.default || m);
    // @ts-ignore
    const viteDevMiddleware = (
      await vite.createServer({
        root,
        server: { middlewareMode: true },
      })
    ).middlewares;
    app.use(viteDevMiddleware);
  }

  // Vike middleware
  app.get('*', async (req, res, next) => {
    const pageContextInit = {
      urlOriginal: req.originalUrl,
      headers: normalizeRequestHeaders(req.headers),
    };

    const pageContext = await renderPage(pageContextInit);
    const { httpResponse } = pageContext;
    if (!httpResponse) {
      return next();
    } else {
      const { body, statusCode, headers } = httpResponse;
      headers.forEach(([name, value]) => res.setHeader(name, value));
      res.status(statusCode).send(body);
    }
  });

  // Use APP_PORT from .env (defaulting to 3000 if not set)
  const port = process.env.APP_PORT || 3000;
  // @ts-ignore
  app.listen(port);
  console.log(`Server running at http://localhost:${port}`);
}

startServer();