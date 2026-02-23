#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: run_evaluator.sh '<research task>'" >&2
  exit 1
fi

TASK="$1"

cat <<EOF
[research-pipeline:evaluator]
Task: $TASK
Status: starting evaluator pipeline
EOF

# This script intentionally stays thin.
# The heavy lifting is done by the OpenClaw agent orchestration layer.

openclaw sessions_spawn \
  --task "Run evaluator research pipeline: $TASK" \
  --label research-evaluator \
  --thinking medium \
  --cleanup keep

cat <<EOF
[research-pipeline:evaluator]
Status: evaluator session spawned
EOF
