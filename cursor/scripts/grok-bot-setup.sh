#!/usr/bin/env bash
# Verify Grok Bot eligibility/install and open the next human steps.
# Usage: ./cursor/scripts/grok-bot-setup.sh
set -euo pipefail

APP="/Applications/Grok Bot.app"
DOCS_PRIVACY="https://cursor.com/dashboard/settings?openPrivacy=true"
DOCS_ONBOARD="https://cursor.com/bot/onboarding?product=grok-bot"
GUIDE="$(cd "$(dirname "$0")/.." && pwd)/docs/grok-bot-setup.md"
FIRST_TASK="$(cd "$(dirname "$0")/.." && pwd)/docs/grok-bot-first-task.txt"

echo "== Grok Bot setup helper =="
echo

# Platform
arch="$(uname -m)"
echo "Platform: macOS $(sw_vers -productVersion) ($arch)"
if [[ "$arch" != "arm64" && "$arch" != "x86_64" ]]; then
  echo "WARN: unexpected architecture; official docs list Apple silicon and Intel only."
fi

# App
if [[ -d "$APP" ]]; then
  ver="$(defaults read "$APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo unknown)"
  bid="$(defaults read "$APP/Contents/Info" CFBundleIdentifier 2>/dev/null || echo unknown)"
  echo "App: installed ($ver, $bid)"
else
  echo "App: NOT installed at $APP"
  echo "Download from $DOCS_ONBOARD"
fi

# Membership / privacy from Cursor local state (read-only)
DB="$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb"
if [[ -f "$DB" ]]; then
  python3 - <<'PY'
import sqlite3, os, json
db = os.path.expanduser("~/Library/Application Support/Cursor/User/globalStorage/state.vscdb")
con = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
cur = con.cursor()
def get(k):
    row = cur.execute("select value from ItemTable where key=?", (k,)).fetchone()
    return row[0] if row else None
plan = get("cursorAuth/stripeMembershipType")
status = get("cursorAuth/stripeSubscriptionStatus")
email = get("cursorAuth/cachedEmail")
priv = get("cursorai/donotchange/newPrivacyMode2")
print(f"Cursor account: {email}")
print(f"Plan: {plan} ({status})")
print(f"Privacy mode blob: {priv}")
eligible = (plan or "").lower() in {"ultra", "team", "business", "enterprise"} or "premium" in (plan or "").lower()
# Ultra is the known individual eligible plan; Teams Premium may appear under other labels.
if (plan or "").lower() == "ultra" and (status or "").lower() == "active":
    print("Eligibility: OK for Grok Bot (Cursor Ultra active)")
else:
    print("Eligibility: confirm SuperGrok Heavy / Ultra / Teams Premium in the dashboard")
if priv and "LEGACY" in str(priv).upper():
    print("Privacy: LEGACY detected — change at dashboard before Grok Bot can start")
elif priv and "NO_TRAINING" in str(priv).upper():
    print("Privacy: PRIVACY_MODE_NO_TRAINING (compatible; not Legacy)")
else:
    print("Privacy: review dashboard setting (Legacy Privacy Mode is unsupported)")
PY
else
  echo "Cursor state DB not found; open dashboard to confirm plan/privacy."
fi

echo
echo "Guide: $GUIDE"
echo "First-task prompt: $FIRST_TASK"
echo

# Open next steps
open -a "Grok Bot" 2>/dev/null || true
open "$DOCS_PRIVACY" || true
open "$DOCS_ONBOARD" || true
if [[ -f "$FIRST_TASK" ]]; then
  pbcopy < "$FIRST_TASK" 2>/dev/null && echo "First-task prompt copied to clipboard."
fi

echo
echo "Next in the app:"
echo "  1. Sign in with Cursor"
echo "  2. Create Bot + set Auto-review / local execution (see guide)"
echo "  3. Paste the first-task prompt (clipboard)"
echo "Done."
