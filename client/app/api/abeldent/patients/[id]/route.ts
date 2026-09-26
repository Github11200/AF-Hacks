import { getPatient } from "@/lib/abeldent";
import { NotFoundError, respond } from "@/lib/abeldent/http";

export async function GET(_req: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return respond(async () => (await getPatient(Number(id))) ?? Promise.reject(new NotFoundError("Patient not found")));
}
