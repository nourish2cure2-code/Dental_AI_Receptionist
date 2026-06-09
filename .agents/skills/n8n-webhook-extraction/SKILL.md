---
name: n8n-webhook-extraction
description: Configures Vapi structured outputs JSON schema, generates Supabase SQL schema for the `leads` table, and routes data via n8n.
---

# Execution Directives:
- Generate JSON schema extracting: patient_name, procedure_interest (enum: veneers, implants, whitening), language_spoken.
- Generate the `CREATE TABLE` SQL command for the Supabase `leads` database table with the columns matching the schema above.
- **Constraint:** Webhook triggers must *exclude* end-of-call-report.
- Webhook triggers must *strictly require* call.analysis.completed.
- Payload mapping logic must target $json.message.artifact.structuredData and map into the n8n Supabase Node.
