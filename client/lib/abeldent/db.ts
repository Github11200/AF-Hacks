import { execFile } from "node:child_process";
import path from "node:path";
import { promisify } from "node:util";

const run = promisify(execFile);

// Same transport the ops scripts use, so app and scripts can't drift apart
const SQL_SCRIPT = process.env.ABELDENT_SQL_SCRIPT ?? path.resolve(process.cwd(), "..", "scripts", "vm_sql.sh");

export type SqlMode = "read" | "write" | "dryRun";
export type Params = Record<string, string | number | boolean | null>;

/** Business-rule rejection raised by our SQL (THROW with a 'VALIDATION:' message). */
export class ValidationError extends Error {}

const MODE_FLAGS: Record<SqlMode, string[]> = { read: [], write: ["--write"], dryRun: ["--dry-run"] };

/** Runs T-SQL in the ABELDent VM and returns the rows of the last result set. */
export async function runSql<T>(sql: string, params: Params = {}, mode: SqlMode = "read"): Promise<T[]> {
  const args = [...MODE_FLAGS[mode], "--params", JSON.stringify(params), sql];
  try {
    const { stdout } = await run(SQL_SCRIPT, args, { timeout: 60_000, maxBuffer: 32 * 1024 * 1024 });
    const sets = stdout.split("\n").filter((l) => l.startsWith("[") || l.startsWith("{"));
    return sets.length ? (JSON.parse(sets[sets.length - 1]) as T[]) : [];
  } catch (err) {
    throw toSqlError(err as { stderr?: string; message: string });
  }
}

function toSqlError(err: { stderr?: string; message: string }): Error {
  const text = err.stderr || err.message;
  // PowerShell wraps SqlException text as: Exception calling "Fill" with "1" argument(s): "<message>"
  const message = text.match(/argument\(s\): "([\s\S]+?)"\s*$/m)?.[1] ?? text.trim();
  return message.startsWith("VALIDATION: ") ? new ValidationError(message.slice(12)) : new Error(message);
}
