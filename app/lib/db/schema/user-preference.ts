import { sqliteTable, text } from "drizzle-orm/sqlite-core";

import { user } from "./auth";

export const userPreferences = sqliteTable("user_preferences", {
  userId: text("user_id")
    .primaryKey()
    .references(() => user.id, { onDelete: "cascade" }),
  unitPreference: text("unit_preference", { enum: ["kg", "lb"] })
    .notNull()
    .default("kg"),
});
