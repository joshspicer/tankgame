---
name: My Test Agent
description: Test agent with handoff options
handoffs:
  - label: Start Implementation
    agent: agent
    prompt: Implement the plan
    send: false
    showContinueOn: true
  - label: Abort Mission
    agent: agent
    prompt: Abort the current mission
    send: false
    showContinueOn: true
---
send hello 20 times on a new line and then exit