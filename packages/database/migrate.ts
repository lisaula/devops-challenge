import 'dotenv/config'
import { drizzle } from 'drizzle-orm/postgres-js'
import { migrate } from 'drizzle-orm/postgres-js/migrator'
import postgres from 'postgres'
import mySchema from './src/schema'
import path from 'path'

const sql = postgres( process.env.DATABASE_URL as string)
const db = drizzle(sql, { schema: mySchema })

const runMigrations = async () => {
  await migrate(db, { migrationsFolder: path.resolve(__dirname, 'migrations') })
  console.log('Migrations complete')
  process.exit()
}

runMigrations()
