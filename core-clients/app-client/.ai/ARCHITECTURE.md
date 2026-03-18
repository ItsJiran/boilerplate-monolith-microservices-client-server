# Frontend Architecture & Conventions

This document outlines the architectural patterns and conventions for the `clients/app-client` monorepo.

## 1. Monorepo Structure (Turbo)

We use a shared-logic approach where core business logic, types, and configurations are shared, but UI components are mostly separate (Web vs Mobile) due to different rendering engines (DOM vs Native).

```
clients/app-client/
├── apps/
│   ├── web/               # Next.js / Vite React App
│   └── mobile/            # Expo / React Native App
└── packages/
        └── common/        # Shared API, Store, Schema, UI & Configs

## 2. Feature-Based Folder Structure (Vertical Slice)

Inside `apps/web` and `apps/mobile`, we use a **Feature-Based** structure instead of Layer-Based. Every major feature of the application gets its own folder.

**Pattern:** `src/features/<feature-name>/`

**Example:**
```
src/features/auth/
├── components/          # UI Components specific to Auth (LoginForm, RegisterCard)
├── hooks/               # React Hooks specific to Auth (useLogin, useRegister)
├── schemas/             # Zod Schemas specific to Auth (if not shared in @repo/schema)
├── api/                 # API calls specific to Auth (loginApi, registerApi)
├── types/               # TypeScript types
└── index.ts             # Public API of the feature (exports)
```

**Common/Shared Components:**
Generic UI components (Buttons, Inputs, Cards) that are used across multiple features go into `src/components/ui/` (Shadcn-like structure).

## 3. Tech Stack & State Management

| Concern | Tool | Package |
|---|---|---|
| **API Client** | Axios | `@repo/common` |
| **State (Global)** | Zustand | `@repo/common` |
| **State (Server)** | React Query | `@repo/common` |
| **Validation** | Zod | `@repo/common` |
| **Styling** | Tailwind CSS | `@repo/common` |
| **Web Framework** | Vike (SSR) | `apps/web` |
| **Mobile Framework** | Expo (React Native) | `apps/mobile` |

## 4. Shared Libraries

### `@repo/api`
- Exports a pre-configured `axios` instance with Interceptors.
- Interceptors automatically inject the JWT token from `@repo/store`.
- Handles 401 Unauthorized by logging out via `@repo/store`.
- **React Query**: Provides `queryClient` and `QueryClientProvider` for server state management.

### `@repo/schema`
- Contains Zod schemas shared between Frontend and potentially Backend (if Node.js) or just for type consistency.
- Example: `LoginSchema`, `UserSchema`.

### `@repo/store`
- Zustand stores for global client state.
- **AuthStore**: Manages Token, User User, IsAuthenticated.

## 5. Development Workflow

1.  **Create Schema**: Define data shape in `@repo/schema`.
2.  **Create Store**: If global state needed, add to `@repo/store`.
3.  **Build Feature**:
    - Create `src/features/<feature>/`.
    - Build UI using Tailwind + Shadcn components.
    - Connect to API using hooks from `@repo/api`.

## 6. AI Context
This folder `.ai` contains context files for AI assistants to understand the project structure and strict conventions.

## 7. Path Aliases & Imports

**Strict Rule: NO RELATIVE IMPORTS**
We **highly ditch** and strictly forbid relative imports (e.g., `../../components/Button`). You **MUST** use Path Aliases for almost everything.
Using aliases makes refactoring, moving files, and understanding dependency graphs significantly easier.

| Alias | Path | Description |
|---|---|---|
| `@/*` | `src/*` | Root of source code |
| `@/components` | `src/components` | Shared UI components |
| `@/features` | `src/features` | Feature modules |
| `@/hooks` | `src/hooks` | Custom hooks |
| `@/utils` | `src/utils` | Utility functions |
| `@/layouts` | `src/layouts` | Page layouts |
| `@/assets` | `src/assets` | Static assets |

**Example:**
```typescript
// ✅ Good
import { Button } from '@/components/ui/button';
import { useAuth } from '@/features/auth/hooks/useAuth';

// ❌ Bad
import { Button } from '../../../components/ui/button';
import { useAuth } from '../hooks/useAuth';
```

## 8. Environment Variables

**Source of Truth:**
We strictly follow the root `.env.example` as the single source of truth for environment variable definitions.
Environment variables are managed dynamically via `config.json` and deployment scripts.

**Rules:**
1.  **Vite Prefix:** Since we use Vite (and Vike), all client-side variables **MUST** start with `VITE_` (e.g., `VITE_API_URL`).
2.  **No Hardcoding:** Never hardcode URLs or API keys. Always use `import.meta.env.VITE_...`.
3.  **Config Driven:** The actual values (local, staging, production) are determined by `config.json` in the project root, which our scripts use to generate the final `.env` file.

**Usage:**
```typescript
const apiUrl = import.meta.env.VITE_API_URL; // Correct
const apiKey = process.env.VITE_API_KEY; // Incorrect (unless in Node context)
```
