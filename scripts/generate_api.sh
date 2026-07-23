#!/usr/bin/env bash
# Regenerates the Dart API client from contracts/openapi.yaml (Principle I).
#
# Idempotent: wipes the previous output and regenerates from scratch.
# Fails loudly (non-zero exit) on an invalid spec or missing Java.
#
# Prerequisites: Java >= 11 (brew install openjdk), Node/npx, Flutter SDK.
set -euo pipefail
cd "$(dirname "$0")/.."

# Homebrew openjdk is keg-only; pick it up when the PATH java is missing or
# is macOS's non-functional /usr/bin/java stub.
if ! java -version >/dev/null 2>&1; then
  export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk}"
  export PATH="$JAVA_HOME/bin:$PATH"
fi
java -version >/dev/null 2>&1 || {
  echo "ERROR: Java runtime not found — brew install openjdk" >&2
  exit 1
}

OUT=packages/livecanvas_api

rm -rf "$OUT"
npx --yes @openapitools/openapi-generator-cli generate \
  -g dart-dio \
  -i contracts/openapi.yaml \
  -o "$OUT" \
  --additional-properties=pubName=livecanvas_api,serializationLibrary=json_serializable

# The dart-dio template pins sdk >=3.5.0, but json_serializable >=6.14 emits
# null-aware elements (Dart >=3.8). Bump the generated constraint so the
# language feature is enabled — automated post-processing, not a hand edit.
sed -i '' "s|sdk: '>=3.5.0 <4.0.0'|sdk: '>=3.8.0 <4.0.0'|" "$OUT/pubspec.yaml"

# The generated package runs its own codegen (json_serializable).
(cd "$OUT" && dart pub get && dart run build_runner build)

dart format "$OUT" >/dev/null
echo "OK: regenerated $OUT from contracts/openapi.yaml"
