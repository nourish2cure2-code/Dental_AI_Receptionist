---
name: build-vapi-web-demo
description: Generates a single-file index.html application using the Vapi Web SDK for offline laptop walk-in pitches.
---

# Execution Directives:
- Output must be exclusively a single index.html file containing embedded CSS and JS.
- Do not use Node.js, React, or build steps.
- Interface must feature a prominent "Start Call" button.
- Script must auto-initialize Vapi instance using provided Public Key and Assistant ID.
- Bind local microphone via navigator.mediaDevices.getUserMedia.
