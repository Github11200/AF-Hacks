import { ValidationError } from "./db";

export class NotFoundError extends Error {}

/** Wraps an ABELDent call as JSON: rule violations → 400, missing → 404, VM/DB failures → 502. */
export async function respond(fn: () => Promise<unknown>, status = 200): Promise<Response> {
  try {
    return Response.json(await fn(), { status });
  } catch (err) {
    const code = err instanceof ValidationError ? 400 : err instanceof NotFoundError ? 404 : 502;
    return Response.json({ error: (err as Error).message }, { status: code });
  }
}

export const isDryRun = (req: Request) => new URL(req.url).searchParams.get("dryRun") === "1";
