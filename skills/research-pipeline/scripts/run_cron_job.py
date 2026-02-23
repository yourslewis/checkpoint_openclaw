#!/usr/bin/env python3
"""
Cron execution helper for research-pipeline.

Responsibilities:
- Load prior state (if any)
- Run a bounded evaluator-style research pass
- Emit a concise delta-oriented summary

This script is designed to be called from an OpenClaw cron job.
"""

import json
import os
import sys
from datetime import datetime

STATE_PATH = os.environ.get("RESEARCH_PIPELINE_STATE", "state.json")

TASK = os.environ.get("RESEARCH_TASK")
if not TASK:
    print("RESEARCH_TASK env var not set", file=sys.stderr)
    sys.exit(1)

previous_state = None
if os.path.exists(STATE_PATH):
    with open(STATE_PATH, "r") as f:
        previous_state = json.load(f)

print("[research-pipeline:cron]")
print(f"Task: {TASK}")
print(f"Run at: {datetime.utcnow().isoformat()}Z")

# Placeholder for evaluator-style logic
# In practice this delegates to the same agent prompts used by evaluator mode

result = {
    "summary": f"Scheduled research update for task: {TASK}",
    "changes": "No diffing logic implemented yet",
    "timestamp": datetime.utcnow().isoformat() + "Z",
}

with open(STATE_PATH, "w") as f:
    json.dump(result, f, indent=2)

print("Summary:")
print(result["summary"])
