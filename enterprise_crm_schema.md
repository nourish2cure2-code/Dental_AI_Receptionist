# Enterprise Tier: The $500/Month CRM Schema

> [!WARNING]
> This is the architecture that justifies the Enterprise check. We are upgrading the payload from a basic "name and procedure" scrape to a highly-lethal psychological profile of the caller. You are handing the clinic's closing team a loaded weapon.

## 1. Vapi Structured Data Schema (JSON)

*Inject this into the Vapi Assistant config under `analysis.structuredDataSchema`.*

```json
{
  "type": "object",
  "properties": {
    "patient_name": {
      "type": "string",
      "description": "First and last name of the caller."
    },
    "procedure_interest": {
      "type": "string",
      "enum": ["all_on_4", "veneers", "implants", "full_mouth_restoration", "whitening", "unknown"],
      "description": "The primary dental procedure the patient needs."
    },
    "urgency_timeline": {
      "type": "string",
      "enum": ["asap", "within_30_days", "within_6_months", "just_browsing"],
      "description": "How soon the patient wants to get the procedure done."
    },
    "financial_status": {
      "type": "string",
      "enum": ["cash_ready", "needs_financing", "price_shopping", "unknown"],
      "description": "Patient's budget expectation and payment method."
    },
    "border_crossing_anxiety": {
      "type": "boolean",
      "description": "Set to true ONLY if the patient expresses fear, hesitation, or asks questions about safety, cartels, or border wait times in Mexicali/Tijuana."
    },
    "travel_origin": {
      "type": "string",
      "description": "The city or state the patient is traveling from (e.g., 'San Diego', 'Arizona')."
    },
    "pain_points": {
      "type": "string",
      "description": "A visceral, 1-2 sentence summary of their dental pain or why they hate their current smile. Use their exact words if possible."
    },
    "competitors_mentioned": {
      "type": "string",
      "description": "Names of any other clinics or quotes they mentioned (e.g., 'My US dentist quoted me $30k', 'Sani Dental')."
    },
    "language_spoken": {
      "type": "string",
      "enum": ["english", "spanish", "spanglish"],
      "description": "The primary language used during the call."
    }
  },
  "required": [
    "patient_name",
    "procedure_interest",
    "urgency_timeline",
    "financial_status",
    "border_crossing_anxiety"
  ]
}
```

## 2. Supabase SQL Schema (The Vault)

*Run this in the Supabase SQL editor. It builds the `enterprise_leads` table.*

```sql
CREATE TABLE enterprise_leads (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    call_id TEXT UNIQUE NOT NULL,
    patient_name TEXT,
    procedure_interest TEXT,
    urgency_timeline TEXT,
    financial_status TEXT,
    border_crossing_anxiety BOOLEAN DEFAULT false,
    travel_origin TEXT,
    pain_points TEXT,
    competitors_mentioned TEXT,
    language_spoken TEXT,
    bot_cost_usd NUMERIC(5, 2), -- Track the exact Vapi burn rate per call
    call_duration_minutes NUMERIC(5, 2)
);

-- Index for fast queries by the clinic's sales team
CREATE INDEX idx_procedure ON enterprise_leads(procedure_interest);
CREATE INDEX idx_urgency ON enterprise_leads(urgency_timeline);
CREATE INDEX idx_anxiety ON enterprise_leads(border_crossing_anxiety);
```

## 3. Supabase Edge Function Intake & Mapping

*Ingestion runs through the `vapi-webhook` Edge Function (`supabase/functions/vapi-webhook/index.ts`, Deno). It catches the Vapi webhook, extracts `message.analysis.structuredData`, and writes to the `enterprise_leads` table with the service-role key. See "Current Architecture" in `CLAUDE.md`.*

### Trigger

* The Vapi assistant's Server URL points to `https://<project-ref>.supabase.co/functions/v1/vapi-webhook`.
* The function processes only the `end-of-call-report` event (which carries the analysis + artifact) and returns `200` for every other event type.

### Filtering

The function early-returns unless `message.type === "end-of-call-report"`, so partial/streaming events never reach the database.

### Field Mapping (Payload Extraction)

The function maps the Vapi `structuredData` artifact into the `enterprise_leads` columns:

| `enterprise_leads` Column | Source (`message…`) |
| :--- | :--- |
| `call_id` | `call.id` |
| `patient_name` | `analysis.structuredData.patient_name` |
| `procedure_interest` | `analysis.structuredData.procedure_interest` |
| `financial_status` | `analysis.structuredData.financial_status` |
| `border_crossing_anxiety` | `analysis.structuredData.border_crossing_anxiety` |
| `pain_points` | `analysis.structuredData.pain_points` |

> [!TIP]
> **The Real Value Add:** After the insert, the Edge Function can fire a **Telnyx SMS** directly. If `border_crossing_anxiety == true`, text the clinic's head closer: *"Hot Lead: John Smith needs All-on-4. Budget is cash-ready. He is scared of the border. Call him immediately with the VIP shuttle pitch."* That SMS alone is worth $500 a month.
