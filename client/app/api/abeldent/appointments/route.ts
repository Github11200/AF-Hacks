import { createAppointment, listAppointments, type NewAppointment } from "@/lib/abeldent";
import { isDryRun, respond } from "@/lib/abeldent/http";

export async function GET(req: Request) {
  const date = new URL(req.url).searchParams.get("date");
  if (!date) return Response.json({ error: "date (YYYY-MM-DD) is required" }, { status: 400 });
  return respond(() => listAppointments(date));
}

export async function POST(req: Request) {
  const body = (await req.json()) as NewAppointment;
  return respond(() => createAppointment(body, { dryRun: isDryRun(req) }), 201);
}
