#!/usr/bin/env bash
# Runs the TextClockCore package tests (phrasing, shared settings and the clock view).
set -euo pipefail
cd "$(dirname "$0")/../Packages/TextClockCore"

swift test "$@"
