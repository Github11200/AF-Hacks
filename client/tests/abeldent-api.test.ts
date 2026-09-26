// Integration: live ABELDent VM (fictional DB). Writes use dryRun, so the DB is left unchanged.
import { describe, expect, it } from "vitest";
import * as appointments from "@/app/api/abeldent/appointments/route";
import * as patient from "@/app/api/abeldent/patients/[id]/route";
import * as patients from "@/app/api/abeldent/patients/route";
import * as providers from "@/app/api/abeldent/providers/route";

const BASE = "http://test/api/abeldent";
const post = (url: string, body: unknown) =>
  new Request(url, { method: "POST", body: JSON.stringify(body), headers: { "content-type": "application/json" } });

describe("ABELDent API", () => {
  it("GET /providers lists active providers", async () => {
    const res = await providers.GET();
    expect(await res.json()).toContainEqual({ id: "T", name: "Dr. Terry Ackerman" });
  });

  it("GET /patients?q searches by name", async () => {
    const res = await patients.GET(new Request(`${BASE}/patients?q=ZZTEST`));
    const body = await res.json();
    expect(body.map((p: { id: number }) => p.id)).toContain(168);
  });

  it("GET /patients/:id returns one patient", async () => {
    const res = await patient.GET(new Request(`${BASE}/patients/168`), { params: Promise.resolve({ id: "168" }) });
    expect(await res.json()).toMatchObject({ id: 168, lastName: "ZZTEST", firstName: "CLAUDE", birthDate: "1990-01-01T00:00:00" });
  });

  it("POST /patients?dryRun=1 validates and inserts without persisting", async () => {
    const res = await patients.POST(
      post(`${BASE}/patients?dryRun=1`, { lastName: "Zzdry", firstName: "Run", birthDate: "2000-02-02", gender: "M", dentistId: "T", phone: "5555550199" }),
    );
    expect(res.status).toBe(201);
    expect(await res.json()).toMatchObject({ lastName: "ZZDRY", firstName: "RUN", phone: "5555550199" });
    const after = await patients.GET(new Request(`${BASE}/patients?q=ZZDRY`));
    expect(await after.json()).toEqual([]);
  });

  it("GET /appointments?date lists the day", async () => {
    const res = await appointments.GET(new Request(`${BASE}/appointments?date=2026-09-28`));
    expect(await res.json()).toContainEqual(
      expect.objectContaining({ patientId: 168, start: "10:30", durationMinutes: 30, chair: "2", providerId: "T" }),
    );
  });

  it("POST /appointments?dryRun=1 books a free slot without persisting", async () => {
    const slot = { patientId: 168, date: "2026-09-28", start: "11:00", durationMinutes: 30, chair: "2", providerId: "T", work: "dry" };
    const res = await appointments.POST(post(`${BASE}/appointments?dryRun=1`, slot));
    expect(res.status).toBe(201);
    expect(await res.json()).toMatchObject({ patientId: 168, start: "11:00", durationMinutes: 30 });
    const day = await (await appointments.GET(new Request(`${BASE}/appointments?date=2026-09-28`))).json();
    expect(day.some((a: { start: string; chair: string }) => a.start === "11:00" && a.chair === "2")).toBe(false);
  });
});
