import { sql } from "drizzle-orm";
import { integer, sqliteTable, text, uniqueIndex } from "drizzle-orm/sqlite-core";

import { users } from "./user";

export const exercises = sqliteTable("exercises", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  name: text("name").notNull(),
  category: text("category", {
    enum: ["push", "pull", "legs", "core", "cardio", "other"],
  }).notNull(),
  isCustom: integer("is_custom", { mode: "boolean" }).notNull().default(false),
  createdByUserId: text("created_by_user_id").references(() => users.id, {
    onDelete: "set null",
  }),
  createdAt: integer("created_at", { mode: "timestamp" })
    .notNull()
    .default(sql`(unixepoch())`),
}, table => [
  // prevent duplicate exercise names per user scope (case-insensitive handled at app level)
  uniqueIndex("exercises_name_created_by_idx").on(table.name, table.createdByUserId),
]);
