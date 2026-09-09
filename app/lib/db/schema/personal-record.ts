import { integer, real, sqliteTable, text, uniqueIndex } from "drizzle-orm/sqlite-core";

import { exercises } from "./exercise";
import { sets } from "./set";
import { users } from "./user";

export const personalRecords = sqliteTable("personal_records", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  userId: text("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  exerciseId: integer("exercise_id")
    .notNull()
    .references(() => exercises.id, { onDelete: "cascade" }),
  setId: integer("set_id")
    .notNull()
    .references(() => sets.id, { onDelete: "cascade" }),
  recordType: text("record_type", {
    enum: ["1rm", "3rm", "5rm", "volume", "estimated_1rm"],
  }).notNull(),
  value: real("value").notNull(),
  achievedAt: integer("achieved_at", { mode: "timestamp" }).notNull(),
}, table => [
  uniqueIndex("pr_user_exercise_type_idx").on(table.userId, table.exerciseId, table.recordType),
]);
