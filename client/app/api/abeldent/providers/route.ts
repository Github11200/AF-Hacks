import { listProviders } from "@/lib/abeldent";
import { respond } from "@/lib/abeldent/http";

export const GET = () => respond(listProviders);
