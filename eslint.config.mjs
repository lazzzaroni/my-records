import antfu from "@antfu/eslint-config";
import eslintPluginTailwindcss from "eslint-plugin-tailwindcss";

// @ts-check
import withNuxt from "./.nuxt/eslint.config.mjs";

export default withNuxt(
  antfu(
    {
      type: "app",
      vue: true,
      typescript: true,
      formatters: true,
      stylistic: {
        indent: 2,
        semi: true,
        quotes: "double",
      },
      ignores: [".pnpm-store/**", "**/migrations/*"],
    },
    {
      rules: {
        "vue/max-attributes-per-line": [
          "error",
          {
            singleline: {
              max: 3,
            },
            multiline: {
              max: 1,
            },
          },
        ],
        "ts/no-redeclare": "off",
        "ts/consistent-type-definitions": ["error", "type"],
        "no-console": ["warn"],
        "antfu/no-top-level-await": ["off"],
        "node/prefer-global/process": ["off"],
        "node/no-process-env": ["error"],
        "perfectionist/sort-imports": [
          "error",
          {
            tsconfig: {
              rootDir: ".",
            },
          },
        ],
      },
    },
  ),
  [
    eslintPluginTailwindcss.configs["flat/recommended"]
    || eslintPluginTailwindcss.configs.recommended,
    {
      files: ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx", "**/*.vue"],
      settings: {
        // Define the tailwindcss settings with the MANDATORY `cssConfigPath`
        tailwindcss: {
          cssConfigPath: "./app/assets/css/tailwind.css",
        },
      },
      // Optional: Customize the rules to your needs
      rules: {
        "tailwindcss/classnames-order": "warn",
        "tailwindcss/no-arbitrary-value": "warn",
        "tailwindcss/no-custom-classname": [
          "warn",
          { whitelist: ["custom\\-*", "inputs"] },
        ],
        "tailwindcss/no-contradicting-classname": "warn",
      },
    },
  ],
);
