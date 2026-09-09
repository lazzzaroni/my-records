import { sqliteTable, text } from "drizzle-orm/sqlite-core";

import { users } from "./user";

export const userPreferences = sqliteTable("user_preferences", {
  userId: text("user_id")
    .primaryKey()
    .references(() => users.id, { onDelete: "cascade" }),
  unitPreference: text("unit_preference", { enum: ["kg", "lb"] })
    .notNull()
    .default("kg"),
});
