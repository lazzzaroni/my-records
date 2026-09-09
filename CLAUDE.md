# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A Nuxt 4 application. Still early-stage: a single home page ([app/pages/index.vue](app/pages/index.vue)) with a nav bar, hero section, and dark/light theme toggle, plus a Drizzle/SQLite database layer (see Architecture below) — no further routes or business logic yet.

## Commands

```bash
npm run dev              # start dev server on http://localhost:3000
npm run build             # production build
npm run generate          # static site generation
npm run preview            # preview production build locally
npm run test               # run all vitest projects
npm run test:watch         # run tests in watch mode
npm run test:unit          # run only the "unit" vitest project (test/unit/*)
npm run test:nuxt          # run only the "nuxt" vitest project (test/nuxt/*)
```

To run a single test file, pass its path through vitest, e.g. `npx vitest test/unit/example.test.ts`.

Database migrations run through drizzle-kit directly (no package.json script wraps it yet): `npx drizzle-kit generate` generates a SQL migration from schema changes in `app/lib/db/schema/`, `npx drizzle-kit migrate` applies pending migrations to the database at `DB_FILE_NAME`.

Linting is provided by `@nuxt/eslint` (config built on `@antfu/eslint-config`, plus `eslint-plugin-tailwindcss` and `eslint-plugin-format`), which generates `.nuxt/eslint.config.mjs`; run it via `npx eslint .` (that generated config is only present after `nuxt prepare`/`postinstall` has run), or `npm run lint` / `npm run lint:fix`. Husky + lint-staged run `npm run lint` on staged files pre-commit.

## Architecture

- **Nuxt 4 app directory structure**: application code lives under `app/` (this is the Nuxt 4 default `srcDir` convention — pages, components, composables, etc. should go in `app/`, not the project root).
- **Module set** (`nuxt.config.ts`): `@nuxt/a11y`, `@nuxt/eslint`, `@nuxt/fonts`, `@nuxt/hints`, `@nuxt/icon`, `@nuxt/image`, `@nuxt/scripts`, `@nuxt/test-utils`, `shadcn-nuxt`, `@vueuse/nuxt`.
- **UI components: use shadcn-vue.** `shadcn-nuxt` is installed and configured (`components.json`: style `new-york`, base color `mauve`, icon library `lucide`, CSS variables on, no class prefix). When building any UI, add/use components from `app/components/ui/` (each component is a folder with an `index.ts` barrel re-exporting its `.vue` file(s) and any `cva` variants, e.g. [app/components/ui/button/index.ts](app/components/ui/button/index.ts)) rather than hand-rolling styled elements or reaching for another component library. Add new components with the shadcn-vue CLI (`npx shadcn-vue@latest add <component>`), which respects the `components.json` aliases (`@/components`, `@/components/ui`, `@/lib`, `@/lib/utils`, `@/composables`). Icons come from `@lucide/vue` (`iconLibrary: "lucide"` in `components.json`), also usable generically via `@nuxt/icon`.
- **Styling: Tailwind CSS v4**, wired in via the `@tailwindcss/vite` plugin (not the PostCSS plugin) in `nuxt.config.ts`, with the stylesheet entry at `app/assets/css/tailwind.css`. Use `cn()` from `app/lib/utils.ts` (clsx + tailwind-merge) to merge/override conditional class lists, and `cva` (class-variance-authority) for components with style variants, following the pattern in existing `app/components/ui/*` components. `tw-animate-css` is available for animation utility classes.
- **Environment variables are validated with a plain `zod` schema**, not read directly from `process.env` elsewhere (an earlier version of this project used `@arkenv/nuxt`, which has since been removed — that dependency and the `arkenv:` config block are gone). The schema lives in [app/lib/env.ts](app/lib/env.ts) (`z.object({ NODE_ENV, DB_FILE_NAME, ... })`), validated eagerly by [app/lib/try-parse-env.ts](app/lib/try-parse-env.ts) (throws a readable error listing every missing/invalid key) and exposed as the named `env` export. `nuxt.config.ts` does a side-effect import (`import "./app/lib/env"`) so invalid env fails Nuxt startup immediately; Node-only tooling that runs outside the Nuxt build (e.g. [drizzle.config.ts](drizzle.config.ts), which drizzle-kit's own CLI loads directly and which can't resolve Nuxt-only module aliases like `#imports`) imports the same file by relative path instead of the `~/` alias. `process.env` may only be touched inside `env.ts`/`try-parse-env.ts` themselves (both carry an `eslint-disable` for `node/no-process-env`). Unlike the old arkenv setup, there is **no automatic server/client split** — every key in `EnvSchema` is available wherever `env` is imported, including client-side code, so don't add a secret to this schema without introducing that separation yourself. Add new env vars to `EnvSchema` in `app/lib/env.ts` and document them in [.env.example](.env.example); copy `.env.example` to `.env` for local values.
- **Database: Drizzle ORM (`drizzle-orm@^1.0.0-rc.4`) over `@tursodatabase/database`**, a local-first SQLite/Turso driver. The client is created in [app/lib/db/index.ts](app/lib/db/index.ts) via `drizzle-orm/tursodatabase/database`, connecting to `env.DB_FILE_NAME` (a local file path, or a Turso URL). Table schema lives in `app/lib/db/schema/` — one file per table (e.g. [app/lib/db/schema/user.ts](app/lib/db/schema/user.ts)), re-exported through `schema/index.ts`; import individual tables from there rather than adding a `schema` option to `drizzle()`. This drizzle-orm version uses Relational Queries v2: the SQLite `drizzle()` config type no longer accepts a `schema` key at all (only `relations`), so `db.query.*` is unavailable until you build a `relations` object with `defineRelations(schema, ...)` from `drizzle-orm` and pass that instead — table-based `db.select()/.insert()/...` queries need no config beyond the connection. Migrations are configured in [drizzle.config.ts](drizzle.config.ts) (`dialect: "sqlite"`, schema path `./app/lib/db/schema/index.ts`, output `./app/lib/db/migrations/`) and driven by the `npx drizzle-kit generate`/`migrate` commands above.
- **Testing is split into two Vitest projects** (configured in [vitest.config.ts](vitest.config.ts)):
  - `unit` — plain Node environment, for logic with no Nuxt runtime dependency. Files go in `test/unit/*.{test,spec}.ts`.
  - `nuxt` — full Nuxt test environment (`@nuxt/test-utils`, happy-dom), for components/composables that need the Nuxt runtime. Files go in `test/nuxt/*.{test,spec}.ts` (directory does not exist yet — create it when the first such test is added).
