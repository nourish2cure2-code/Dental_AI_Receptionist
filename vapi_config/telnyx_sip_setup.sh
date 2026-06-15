#!/bin/bash

# ==============================================================================
# Telnyx SIP -> Vapi Configuration Script
# Run this from Git Bash or WSL.
# It binds the Telnyx number to your Spanglish Assistant.
# ==============================================================================

# Load secrets from .env (never hardcode keys). Resolve .env relative to this
# script so it works no matter the current working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set -a
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../.env"
set +a

# Map .env variable names to what this script uses.
ASSISTANT_ID="$VAPI_ASSISTANT_ID"
TELNYX_NUMBER="$TELNYX_PHONE_NUMBER"

# Fail fast if anything required is missing.
: "${VAPI_PRIVATE_KEY:?Set VAPI_PRIVATE_KEY in .env}"
: "${ASSISTANT_ID:?Set VAPI_ASSISTANT_ID in .env}"
: "${TELNYX_NUMBER:?Set TELNYX_PHONE_NUMBER in .env}"

echo "Deploying Telnyx SIP Trunk to Vapi (assistant $ASSISTANT_ID, number $TELNYX_NUMBER)..."

# Bind the number directly to the Spanglish assistant
curl --request POST \
  --url https://api.vapi.ai/phone-number \
  --header "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  --header "Content-Type: application/json" \
  --data '{
    "provider": "sip",
    "number": "'"$TELNYX_NUMBER"'",
    "assistantId": "'"$ASSISTANT_ID"'",
    "name": "Telnyx Primary MX Routing"
  }'

echo -e "\n\nPayload fired. Check your Vapi dashboard."

# ==============================================================================
# MANUAL TELNYX DASHBOARD STEPS (CRITICAL)
# ==============================================================================
# You cannot do this via Vapi's API. You MUST do this in the Telnyx portal:
#
# 1. Go to "SIP Connections" in Telnyx.
# 2. Create a new SIP Connection (Call it "Vapi Spanglish Routing").
# 3. Under "Outbound", set the SIP URI to: sip.vapi.ai
# 4. Under "Inbound", change routing method to "SIP URI" and point it to:
#    sip:<your-telnyx-number>@sip.vapi.ai
# 5. Go to "Numbers" -> "My Numbers" and assign your Telnyx number to this SIP connection.
#
# The moment a call hits that number, Telnyx shunts the raw stream to Vapi,
# at the raw Telnyx SIP rate. 11 cents a minute locked.
