import { drizzle } from "drizzle-orm/tursodatabase/database";

import env from "~/lib/env";
// You can specify any property from the turso connection options
const db = drizzle({ connection: { path: env.DB_FILE_NAME } });

export default db;
