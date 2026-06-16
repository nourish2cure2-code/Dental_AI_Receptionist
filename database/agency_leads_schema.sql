-- Supabase Schema for Baja Dental AI — B2B Agency Leads
-- Stores leads of clinic owners inquiring about the AI Receptionist.

CREATE TABLE IF NOT EXISTS public.agency_leads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    call_id TEXT UNIQUE NOT NULL,
    clinic_name TEXT,
    owner_name TEXT,
    phone_number TEXT,
    current_reception_pain TEXT,
    pilot_appointment TEXT,
    summary TEXT
);

-- Enable RLS to keep this private to the agency owner
ALTER TABLE public.agency_leads ENABLE ROW LEVEL SECURITY;

-- Only authenticated users (or service role) can view/insert
CREATE POLICY "Allow authenticated access to agency leads" ON public.agency_leads
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);
