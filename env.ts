import arkenv from "@arkenv/nuxt";

export const env = arkenv({
  NODE_ENV: "'development' | 'production' | 'test' = 'development'",
});
