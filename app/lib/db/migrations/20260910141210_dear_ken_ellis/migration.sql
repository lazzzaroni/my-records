CREATE TABLE `account` (
	`id` text PRIMARY KEY,
	`account_id` text NOT NULL,
	`provider_id` text NOT NULL,
	`user_id` text NOT NULL,
	`access_token` text,
	`refresh_token` text,
	`id_token` text,
	`access_token_expires_at` integer,
	`refresh_token_expires_at` integer,
	`scope` text,
	`password` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer NOT NULL,
	CONSTRAINT `fk_account_user_id_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE
);
--> statement-breakpoint
CREATE TABLE `session` (
	`id` text PRIMARY KEY,
	`expires_at` integer NOT NULL,
	`token` text NOT NULL UNIQUE,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer NOT NULL,
	`ip_address` text,
	`user_agent` text,
	`user_id` text NOT NULL,
	CONSTRAINT `fk_session_user_id_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE
);
--> statement-breakpoint
CREATE TABLE `user` (
	`id` text PRIMARY KEY,
	`name` text NOT NULL,
	`email` text NOT NULL UNIQUE,
	`email_verified` integer DEFAULT false NOT NULL,
	`image` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL
);
--> statement-breakpoint
CREATE TABLE `verification` (
	`id` text PRIMARY KEY,
	`identifier` text NOT NULL,
	`value` text NOT NULL,
	`expires_at` integer NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL
);
--> statement-breakpoint
PRAGMA foreign_keys=OFF;--> statement-breakpoint
CREATE TABLE `__new_exercises` (
	`id` integer PRIMARY KEY AUTOINCREMENT,
	`name` text NOT NULL,
	`category` text NOT NULL,
	`is_custom` integer DEFAULT false NOT NULL,
	`created_by_user_id` text,
	`created_at` integer DEFAULT (unixepoch()) NOT NULL,
	CONSTRAINT `fk_exercises_created_by_user_id_user_id_fk` FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`) ON DELETE SET NULL
);
--> statement-breakpoint
INSERT INTO `__new_exercises`(`id`, `name`, `category`, `is_custom`, `created_by_user_id`, `created_at`) SELECT `id`, `name`, `category`, `is_custom`, `created_by_user_id`, `created_at` FROM `exercises`;--> statement-breakpoint
DROP TABLE `exercises`;--> statement-breakpoint
ALTER TABLE `__new_exercises` RENAME TO `exercises`;--> statement-breakpoint
PRAGMA foreign_keys=ON;--> statement-breakpoint
PRAGMA foreign_keys=OFF;--> statement-breakpoint
CREATE TABLE `__new_personal_records` (
	`id` integer PRIMARY KEY AUTOINCREMENT,
	`user_id` text NOT NULL,
	`exercise_id` integer NOT NULL,
	`set_id` integer NOT NULL,
	`record_type` text NOT NULL,
	`value` real NOT NULL,
	`achieved_at` integer NOT NULL,
	CONSTRAINT `fk_personal_records_user_id_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
	CONSTRAINT `fk_personal_records_exercise_id_exercises_id_fk` FOREIGN KEY (`exercise_id`) REFERENCES `exercises`(`id`) ON DELETE CASCADE,
	CONSTRAINT `fk_personal_records_set_id_sets_id_fk` FOREIGN KEY (`set_id`) REFERENCES `sets`(`id`) ON DELETE CASCADE
);
--> statement-breakpoint
INSERT INTO `__new_personal_records`(`id`, `user_id`, `exercise_id`, `set_id`, `record_type`, `value`, `achieved_at`) SELECT `id`, `user_id`, `exercise_id`, `set_id`, `record_type`, `value`, `achieved_at` FROM `personal_records`;--> statement-breakpoint
DROP TABLE `personal_records`;--> statement-breakpoint
ALTER TABLE `__new_personal_records` RENAME TO `personal_records`;--> statement-breakpoint
PRAGMA foreign_keys=ON;--> statement-breakpoint
PRAGMA foreign_keys=OFF;--> statement-breakpoint
CREATE TABLE `__new_user_preferences` (
	`user_id` text PRIMARY KEY,
	`unit_preference` text DEFAULT 'kg' NOT NULL,
	CONSTRAINT `fk_user_preferences_user_id_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE
);
--> statement-breakpoint
INSERT INTO `__new_user_preferences`(`user_id`, `unit_preference`) SELECT `user_id`, `unit_preference` FROM `user_preferences`;--> statement-breakpoint
DROP TABLE `user_preferences`;--> statement-breakpoint
ALTER TABLE `__new_user_preferences` RENAME TO `user_preferences`;--> statement-breakpoint
PRAGMA foreign_keys=ON;--> statement-breakpoint
PRAGMA foreign_keys=OFF;--> statement-breakpoint
CREATE TABLE `__new_workouts` (
	`id` integer PRIMARY KEY AUTOINCREMENT,
	`user_id` text NOT NULL,
	`date` integer NOT NULL,
	`notes` text,
	`created_at` integer DEFAULT (unixepoch()) NOT NULL,
	`deleted_at` integer,
	CONSTRAINT `fk_workouts_user_id_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE
);
--> statement-breakpoint
INSERT INTO `__new_workouts`(`id`, `user_id`, `date`, `notes`, `created_at`, `deleted_at`) SELECT `id`, `user_id`, `date`, `notes`, `created_at`, `deleted_at` FROM `workouts`;--> statement-breakpoint
DROP TABLE `workouts`;--> statement-breakpoint
ALTER TABLE `__new_workouts` RENAME TO `workouts`;--> statement-breakpoint
PRAGMA foreign_keys=ON;--> statement-breakpoint
CREATE UNIQUE INDEX `exercises_name_created_by_idx` ON `exercises` (`name`,`created_by_user_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `pr_user_exercise_type_idx` ON `personal_records` (`user_id`,`exercise_id`,`record_type`);--> statement-breakpoint
CREATE INDEX `workouts_user_date_idx` ON `workouts` (`user_id`,`date`);--> statement-breakpoint
CREATE INDEX `account_userId_idx` ON `account` (`user_id`);--> statement-breakpoint
CREATE INDEX `session_userId_idx` ON `session` (`user_id`);--> statement-breakpoint
CREATE INDEX `verification_identifier_idx` ON `verification` (`identifier`);--> statement-breakpoint
DROP TABLE `users`;