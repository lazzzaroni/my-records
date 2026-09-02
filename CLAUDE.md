# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A Nuxt 4 application (currently a minimal starter — `app/app.vue` still renders `<NuxtWelcome />`, no routes or business logic exist yet).

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

Linting is provided by `@nuxt/eslint` (config built on `@antfu/eslint-config`, plus `eslint-plugin-tailwindcss` and `eslint-plugin-format`), which generates `.nuxt/eslint.config.mjs`; run it via `npx eslint .` (that generated config is only present after `nuxt prepare`/`postinstall` has run), or `npm run lint` / `npm run lint:fix`. Husky + lint-staged run `npm run lint` on staged files pre-commit.

## Architecture

- **Nuxt 4 app directory structure**: application code lives under `app/` (this is the Nuxt 4 default `srcDir` convention — pages, components, composables, etc. should go in `app/`, not the project root).
- **Module set** (`nuxt.config.ts`): `@nuxt/a11y`, `@nuxt/eslint`, `@nuxt/fonts`, `@nuxt/hints`, `@nuxt/icon`, `@nuxt/image`, `@nuxt/scripts`, `@nuxt/test-utils`, `@arkenv/nuxt`, `shadcn-nuxt`.
- **UI components: use shadcn-vue.** `shadcn-nuxt` is installed and configured (`components.json`: style `new-york`, base color `mauve`, icon library `lucide`, CSS variables on, no class prefix). When building any UI, add/use components from `app/components/ui/` (each component is a folder with an `index.ts` barrel re-exporting its `.vue` file(s) and any `cva` variants, e.g. [app/components/ui/button/index.ts](app/components/ui/button/index.ts)) rather than hand-rolling styled elements or reaching for another component library. Add new components with the shadcn-vue CLI (`npx shadcn-vue@latest add <component>`), which respects the `components.json` aliases (`@/components`, `@/components/ui`, `@/lib`, `@/lib/utils`, `@/composables`). Icons come from `@lucide/vue` (`iconLibrary: "lucide"` in `components.json`), also usable generically via `@nuxt/icon`.
- **Styling: Tailwind CSS v4**, wired in via the `@tailwindcss/vite` plugin (not the PostCSS plugin) in `nuxt.config.ts`, with the stylesheet entry at `app/assets/css/tailwind.css`. Use `cn()` from `app/lib/utils.ts` (clsx + tailwind-merge) to merge/override conditional class lists, and `cva` (class-variance-authority) for components with style variants, following the pattern in existing `app/components/ui/*` components. `tw-animate-css` is available for animation utility classes.
- **Environment variables are validated via `@arkenv/nuxt`** (the Nuxt-aware `arkenv` build, imported from `@arkenv/nuxt` — not the bare `arkenv` package, which doesn't understand Nuxt's runtime config), not read directly from `process.env`. Schema and defaults live in [env.ts](env.ts) using the **flat layout**: one schema object with arktype syntax (e.g. `"string = 'default'"`) per key. Server/client/shared placement is inferred automatically — keys named `NUXT_PUBLIC_*` become client-exposed, `NODE_ENV` is shared, everything else is server-only (private `runtimeConfig`, never sent to the client bundle). Add new env vars directly to the schema in `env.ts` rather than accessing `process.env` ad hoc; do not use the older nested `{ server, client, shared }` object shape — it's deprecated and logs a warning. Copy [.env.example](.env.example) to `.env` for local values.
- **Testing is split into two Vitest projects** (configured in [vitest.config.ts](vitest.config.ts)):
  - `unit` — plain Node environment, for logic with no Nuxt runtime dependency. Files go in `test/unit/*.{test,spec}.ts`.
  - `nuxt` — full Nuxt test environment (`@nuxt/test-utils`, happy-dom), for components/composables that need the Nuxt runtime. Files go in `test/nuxt/*.{test,spec}.ts` (directory does not exist yet — create it when the first such test is added).
