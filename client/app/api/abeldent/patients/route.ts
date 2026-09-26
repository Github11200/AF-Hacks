import { createPatient, searchPatients, type NewPatient } from "@/lib/abeldent";
import { isDryRun, respond } from "@/lib/abeldent/http";

export const GET = (req: Request) => respond(() => searchPatients(new URL(req.url).searchParams.get("q") ?? ""));

export async function POST(req: Request) {
  const body = (await req.json()) as NewPatient;
  return respond(() => createPatient(body, { dryRun: isDryRun(req) }), 201);
}
