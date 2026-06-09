---
name: twilio-vapi-bridge
description: Generates configuration commands to route an inbound +52 Twilio number directly to a Vapi.ai assistant bypassing SIP trunking.
---

# Execution Directives:
- Generate curl POST commands targeting Vapi /phone-number endpoint.
- Map twilioAccountSid and twilioAuthToken to the specified Vapi assistantId.
- Configure Twilio inbound webhook URL to point to Vapi inbound SIP/Webhook handler.
