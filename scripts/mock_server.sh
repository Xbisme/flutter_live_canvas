#!/usr/bin/env bash
# Local mock backend for UI development (MO-002, US4 / FR-014).
#
# Serves the contract (contracts/openapi.yaml v0.3.2) with Prism, returning
# schema-valid sample responses so the app can be built without the real
# backend. Point the app at it by running the development flavor with
#   --dart-define=USE_MOCK=true
# (see AppConfig.development()); default dev still targets the local backend.
#
# Requires node/npm (uses npx — no global install). Stop with Ctrl-C.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${1:-4010}"

echo "→ Prism mock on http://localhost:${PORT} (contracts/openapi.yaml)"
exec npx --yes @stoplight/prism-cli@5.16.0 mock \
  "$ROOT/contracts/openapi.yaml" -p "$PORT" --host 0.0.0.0
