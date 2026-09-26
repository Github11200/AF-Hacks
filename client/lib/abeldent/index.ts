import { runSql } from "./db";
import * as SQL from "./sql";

export { ValidationError } from "./db";

export type Provider = { id: string; name: string };

export type Patient = {
  id: number;
  lastName: string;
  firstName: string;
  birthDate: string | null;
  gender: string;
  phone: string | null;
  mobile: string | null;
  email: string | null;
  dentistId: string;
  inactive: boolean;
};

export type NewPatient = {
  lastName: string;
  firstName: string;
  birthDate: string;
  gender: "F" | "M" | "";
  dentistId: string;
  phone?: string;
  mobile?: string;
  email?: string;
};

export type Appointment = {
  id: string;
  patientId: number;
  patientName: string | null;
  date: string;
  start: string;
  durationMinutes: number;
  chair: string;
  providerId: string;
  statusCode: string;
  status: string | null;
  work: string;
};

export type NewAppointment = {
  patientId: number;
  date: string;
  start: string;
  durationMinutes: number;
  chair: string;
  providerId: string;
  work?: string;
};

/** Write options: dryRun validates and runs the insert, then rolls it back. */
export type WriteOptions = { dryRun?: boolean };

export const listProviders = () => runSql<Provider>(SQL.LIST_PROVIDERS);

export const searchPatients = (q = "") => runSql<Patient>(SQL.SEARCH_PATIENTS, { q });

export async function getPatient(id: number): Promise<Patient | null> {
  const [row] = await runSql<Patient>(SQL.GET_PATIENT, { pid: id });
  return row ?? null;
}

export async function createPatient(p: NewPatient, { dryRun = false }: WriteOptions = {}): Promise<Patient> {
  const params = { phone: "", mobile: "", email: "", ...p };
  const [row] = await runSql<Patient>(SQL.CREATE_PATIENT, params, dryRun ? "dryRun" : "write");
  return row;
}

export const listAppointments = (date: string) => runSql<Appointment>(SQL.LIST_APPOINTMENTS, { date });

export async function createAppointment(a: NewAppointment, { dryRun = false }: WriteOptions = {}): Promise<Appointment> {
  const [row] = await runSql<Appointment>(SQL.CREATE_APPOINTMENT, { work: "", ...a }, dryRun ? "dryRun" : "write");
  return row;
}
