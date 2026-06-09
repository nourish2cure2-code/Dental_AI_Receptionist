# **SYSTEM INGESTION FILE: AGENT SKILL ARCHITECTURE**

## **1\. Environment Configuration: Gemini 3.1 Pro Binding**

To enforce Gemini 3.1 Pro reasoning for complex autonomous orchestration within the Antigravity IDE, instantiate the following configuration at \<workspace-root\>/.agents/settings.json.

{  
  "antigravity.ai.model": "gemini-3.1-pro",  
  "antigravity.agent.enabled": true,  
  "antigravity.agent.model": "gemini-3.1-pro"  
}

## **2\. Directory Architecture & Symlink Protocol**

Agent skills adhere to the agentskills.io standard. Maintain a unified source of truth by developing in the Claude Code directory and symlinking to the Antigravity IDE directory.

**Standard Project Directory:**

\<workspace-root\>/.claude/skills/\<skill-name\>/SKILL.md

**Antigravity IDE Directory:**

\<workspace-root\>/.agents/skills/\<skill-name\>/SKILL.md

**Execution Protocol (Terminal):**

mkdir \-p .claude/skills  
mkdir \-p .agents/skills  
\# Develop skills in .claude/skills, then symlink for Gemini 3.1 Pro access  
ln \-s $(pwd)/.claude/skills/\* $(pwd)/.agents/skills/

## **3\. Required Skill Definitions (SKILL.md Payloads)**

Inject the following payloads into their respective directories to orchestrate the dental receptionist pipeline.

### **Skill 1: Bilingual Prompt Engineering (Spanglish)**

**Path:** .claude/skills/vapi-spanglish-persona/SKILL.md

\---  
name: vapi-spanglish-persona  
description: Generates deterministic Vapi.ai system prompts enforcing Northern Mexican Spanish and fluent English code-switching for Mexicali dental clinics (All-on-4, veneers).  
\---

**Execution Directives:**

* Provider must be cartesia.  
* Model must be gemini-1.5-pro or gpt-4o.  
* Transcriber must be deepgram (conversational model).  
* **Constraint:** System prompt must explicitly instruct the agent: "You are a receptionist in Mexicali. Speak Northern Mexican Spanish. If the caller speaks English, instantly switch to fluent, unaccented English."

### **Skill 2: Web SDK Demonstration Scaffolding**

**Path:** .claude/skills/build-vapi-web-demo/SKILL.md

\---  
name: build-vapi-web-demo  
description: Generates a single-file index.html application using the Vapi Web SDK for offline laptop walk-in pitches.  
\---

**Execution Directives:**

* Output must be exclusively a single index.html file containing embedded CSS and JS.  
* Do not use Node.js, React, or build steps.  
* Interface must feature a prominent "Start Call" button.  
* Script must auto-initialize Vapi instance using provided Public Key and Assistant ID.  
* Bind local microphone via navigator.mediaDevices.getUserMedia.

### **Skill 3: Structured Output, Supabase & Webhook Routing**

**Path:** .claude/skills/n8n-webhook-extraction/SKILL.md

---  
name: n8n-webhook-extraction  
description: Configures Vapi structured outputs JSON schema, generates Supabase SQL schema for the `leads` table, and routes data via n8n.  
---

**Execution Directives:**

* Generate JSON schema extracting: patient\_name, procedure\_interest (enum: veneers, implants, whitening), language\_spoken.  
* Generate the `CREATE TABLE` SQL command for the Supabase `leads` database table.
* **Constraint:** Webhook triggers must *exclude* end-of-call-report.  
* Webhook triggers must *strictly require* call.analysis.completed.  
* Payload mapping logic must target $json.message.artifact.structuredData and map into the n8n Supabase Node.

### **Skill 4: Twilio VoIP Bootstrap Provisioning**

**Path:** .claude/skills/twilio-vapi-bridge/SKILL.md

\---  
name: twilio-vapi-bridge  
description: Generates configuration commands to route an inbound \+52 Twilio number directly to a Vapi.ai assistant bypassing SIP trunking.  
\---

**Execution Directives:**

* Generate curl POST commands targeting Vapi /phone-number endpoint.  
* Map twilioAccountSid and twilioAuthToken to the specified Vapi assistantId.  
* Configure Twilio inbound webhook URL to point to Vapi inbound SIP/Webhook handler.