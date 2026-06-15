-- Supabase Schema for Baja Dental AI CRM

-- Create the leads table to store structured data from Vapi calls
CREATE TABLE public.leads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    patient_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    procedure_interest TEXT CHECK (procedure_interest IN ('implants', 'veneers', 'whitening', 'other', 'unknown')),
    language_spoken TEXT CHECK (language_spoken IN ('es', 'en', 'bilingual', 'unknown')),
    call_summary TEXT,
    vapi_call_id TEXT UNIQUE
);

-- Enable Row Level Security (optional, for front-end access)
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users (assuming clinic staff logs in)
CREATE POLICY "Allow authenticated access" ON public.leads
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);
