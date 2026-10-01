#!/usr/bin/env bash
# Builds a Developer ID signed TextClock.app, notarizes and staples it, and packages
# build/TextClock.zip for distribution.
#
# Notarizing needs a notarytool keychain profile for the team in project.yml. Profiles aren't tied
# to one app, so the one made for Mould works. To create one (use an app-specific password from
# https://account.apple.com):
#
#   xcrun notarytool store-credentials mould-notary \
#     --apple-id you@example.com --team-id HFFHH9CJYF
#
# Usage: scripts/release.sh [--publish]
#   --publish   also create the GitHub release v<version> with the zip attached
# Uses the keychain profile in NOTARY_PROFILE (default: mould-notary).
set -euo pipefail
cd "$(dirname "$0")/.."

PROFILE="${NOTARY_PROFILE:-mould-notary}"
TEAM_ID="$(sed -n 's/^ *DEVELOPMENT_TEAM: *//p' project.yml | head -1)"
BUILD="build"
APP="$BUILD/TextClock.app"
ZIP="$BUILD/TextClock.zip"

PUBLISH=false
[ "${1:-}" = "--publish" ] && PUBLISH=true

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

# macOS registers every TextClock.app it sees and may run the widget from any of them. If that
# copy is later deleted (as the next release does with build/), the widget stops loading. So
# keep the copies in build/ unregistered, then re-register the app that's actually used:
# unregistering also drops the App Intents metadata the widget needs to read its configuration.
forget_build_copies() {
  find "$BUILD" -name TextClock.app -type d -prune 2>/dev/null | while read -r app; do
    pluginkit -r "$app/Contents/PlugIns/TextClockWidget.appex" 2>/dev/null || true
    "$LSREGISTER" -u "$app" 2>/dev/null || true
  done
  for app in /Applications/TextClock.app DerivedData/Build/Products/Debug/TextClock.app; do
    if [ -d "$app" ]; then
      "$LSREGISTER" -f -R "$app"
      break
    fi
  done
}

command -v xcodegen >/dev/null || { echo "XcodeGen is missing; install it with 'brew install xcodegen'." >&2; exit 1; }
if $PUBLISH && [ -n "$(git status --porcelain)" ]; then
  echo "The working tree has uncommitted changes; commit them before publishing a release." >&2
  exit 1
fi

# Fail before the slow build if the notary credentials aren't there (or the keychain is locked).
xcrun notarytool history --keychain-profile "$PROFILE" >/dev/null 2>&1 || {
  echo "Can't use notary profile '$PROFILE'. Create it (see the top of this script), unlock the" >&2
  echo "login keychain, or set NOTARY_PROFILE to an existing profile." >&2
  exit 1
}

forget_build_copies
rm -rf "$BUILD"
mkdir -p "$BUILD"
xcodegen generate --quiet

cat > "$BUILD/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>method</key><string>developer-id</string>
  <key>teamID</key><string>$TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
</dict></plist>
EOF

echo "Archiving..."
xcodebuild -project TextClock.xcodeproj -scheme TextClock -configuration Release \
  -archivePath "$BUILD/TextClock.xcarchive" -derivedDataPath "$BUILD/DerivedData" -allowProvisioningUpdates -quiet archive
xcodebuild -exportArchive -archivePath "$BUILD/TextClock.xcarchive" \
  -exportOptionsPlist "$BUILD/ExportOptions.plist" -exportPath "$BUILD" -allowProvisioningUpdates -quiet
codesign --verify --deep --strict "$APP"

# The notary service takes a zip; ditto keeps the bundle's metadata intact.
ditto -c -k --keepParent "$APP" "$ZIP"
echo "Submitting to Apple's notary service (usually a few minutes)..."
xcrun notarytool submit "$ZIP" --keychain-profile "$PROFILE" --wait

# Staple the ticket so Gatekeeper can verify offline, then re-zip the stapled app.
xcrun stapler staple "$APP"
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
spctl --assess --type execute --verbose "$APP"
forget_build_copies

VERSION="$(plutil -extract CFBundleShortVersionString raw "$APP/Contents/Info.plist")"
echo "Notarized and stapled: $APP (version $VERSION)"
echo "Ready to share: $ZIP"

if $PUBLISH; then
  gh release create "v$VERSION" "$ZIP" --target "$(git rev-parse HEAD)" --title "Text Clock $VERSION" \
    --notes "Download \`TextClock.zip\`, unzip it, move \`TextClock.app\` to /Applications and launch it once. Then right-click the desktop → Edit Widgets… → search \"Text Clock\". Signed with a Developer ID and notarized by Apple." \
    --generate-notes
fi
