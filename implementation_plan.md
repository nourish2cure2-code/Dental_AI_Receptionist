# Project Deep Dive & Architectural Correction

You are entirely right, and I missed the killshot sitting right in your repo. My previous read assumed a low-code automation bridge for ingestion.

But I just did a deep dive into your codebase (`c:\Users\DELL\ai mexico\supabase\functions\vapi-webhook\index.ts`). You've gone straight to a **Supabase Edge Function** in Deno that natively catches the Vapi webhook, rips the `structuredData` out of the payload, and injects it directly into the `leads` table using the Service Role Key.

That is infinitely leaner, faster, and cheaper than routing through a separate automation container.

Here is the exact state of your current pipeline and how we are going to upgrade it to handle the $500/month Enterprise Tier and Live Booking.

## 1. The Current State (What I found)
Your Edge Function currently:
- ONLY listens for `end-of-call-report` events.
- Extracts a basic payload: `patient_name`, `procedure_interest`, `language_spoken`, `summary`.
- Inserts it into the `leads` table.
- Does **not** handle mid-call tool execution (like checking calendars).

## 2. The Required Upgrade (The Enterprise Edge)
To justify the $500/month Enterprise tier and achieve live booking without adding any separate automation layer, we need to upgrade your Edge Function to act as a **Unified Vapi Server URL**.

It needs to handle three distinct Vapi webhook types:
1. `tool-calls`: Fired mid-call when Sofia needs to check calendar availability.
2. `tool-calls` (Booking): Fired mid-call when Sofia locks in the appointment.
3. `end-of-call-report`: Fired when they hang up to dump the heavy Enterprise CRM schema (anxiety profiling, budget) into the database.

> [!WARNING]
> **User Review Required: SMS Alerting from the Edge Function**
> In my previous schema, I suggested a separate automation layer to fire an instant SMS if the caller had `border_crossing_anxiety`. Since we keep everything in Supabase, we will execute that SMS *directly* from the Supabase Edge Function using your Telnyx API keys. Do you approve injecting the Telnyx SDK/cURL into the Edge Function?

## Proposed Changes

### `supabase/functions/vapi-webhook/index.ts`
We will rewrite the Edge Function to become a multi-route switchboard.

#### [MODIFY] [index.ts](file:///c:/Users/DELL/ai%20mexico/supabase/functions/vapi-webhook/index.ts)
- **Add Router Logic:** `if (msg.type === "tool-calls") { ... } else if (msg.type === "end-of-call-report") { ... }`
- **Tool Logic (checkCalendarAvailability):** Mock a simple calendar return or query a real API.
- **Tool Logic (bookAppointment):** Insert the confirmed appointment directly into a new `appointments` table in Supabase.
- **Enterprise Payload Extraction:** Update the `end-of-call-report` extraction to grab `border_crossing_anxiety`, `urgency_timeline`, `financial_status`, etc.
- **Telnyx Alerting (Optional):** If `border_crossing_anxiety == true`, fire an HTTP request to Telnyx to text the clinic owner.

### `database/schema.sql` (or similar migration)
We need to update your Supabase database to support the new data.

#### [NEW] [enterprise_migration.sql](file:///c:/Users/DELL/ai%20mexico/database/enterprise_migration.sql)
- `ALTER TABLE leads` to add the new Enterprise columns (`border_crossing_anxiety`, `financial_status`, `urgency_timeline`).
- `CREATE TABLE appointments` to store the live-booked slots.

## Verification Plan
1. **Local Edge Function Test:** Use the Supabase CLI (`supabase functions serve`) and `curl` to fire a mock Vapi `tool-calls` payload to verify the Edge Function returns the correct JSON response to Vapi.
2. **Live Call Test:** Execute a call to the Telnyx number. Ask for an appointment on Tuesday. Watch the Edge Function logs to see the `checkCalendarAvailability` and `bookAppointment` tools fire in real-time.
3. **Database Check:** Verify the lead and the appointment populate in Supabase.

Does this architectural shift match your vision for keeping the stack lean with no separate automation layer? If so, approve this plan and I'll gut the Edge Function and rebuild it.
