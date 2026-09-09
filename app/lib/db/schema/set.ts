import { sql } from "drizzle-orm";
import { index, integer, real, sqliteTable } from "drizzle-orm/sqlite-core";

import { exercises } from "./exercise";
import { workouts } from "./workout";

export const sets = sqliteTable("sets", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  workoutId: integer("workout_id")
    .notNull()
    .references(() => workouts.id, { onDelete: "cascade" }),
  exerciseId: integer("exercise_id")
    .notNull()
    .references(() => exercises.id, { onDelete: "restrict" }),
  setNumber: integer("set_number").notNull(),
  weight: real("weight").notNull(),
  reps: integer("reps").notNull(),
  rpe: real("rpe"),
  isWarmup: integer("is_warmup", { mode: "boolean" }).notNull().default(false),
  bodyweightAtTime: real("bodyweight_at_time"),
  createdAt: integer("created_at", { mode: "timestamp" })
    .notNull()
    .default(sql`(unixepoch())`),
}, table => [
  // speeds up PR queries: MAX(weight) per user+exercise
  index("sets_exercise_idx").on(table.exerciseId),
  index("sets_workout_idx").on(table.workoutId),
]);
