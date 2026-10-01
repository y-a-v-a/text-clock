#!/usr/bin/env bash
# Generates the Xcode project and builds a Debug TextClock.app into DerivedData/.
#
# Usage: scripts/build.sh [--run]
#   --run   quit any running copy and launch the fresh build, so macOS picks up the new widget
set -euo pipefail
cd "$(dirname "$0")/.."

APP="DerivedData/Build/Products/Debug/TextClock.app"

command -v xcodegen >/dev/null || { echo "XcodeGen is missing; install it with 'brew install xcodegen'." >&2; exit 1; }
xcodegen generate --quiet

# -allowProvisioningUpdates lets Xcode create the signing assets for the team in project.yml.
xcodebuild -project TextClock.xcodeproj -scheme TextClock -configuration Debug \
  -destination "generic/platform=macOS" -derivedDataPath DerivedData -allowProvisioningUpdates -quiet build
echo "Built: $APP"

if [ "${1:-}" = "--run" ]; then
  pkill -x TextClock 2>/dev/null && sleep 1 || true
  open "$APP"
fi
