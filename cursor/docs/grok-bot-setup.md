# Grok Bot setup (Cursor Ultra)

**Date:** 2026-08-12  
**Status:** Installed and exercised on this Mac (Ultra active). First Bot **Call Coach** created; settings verified; read-only docs task completed.  
**Official docs:** [Get started](https://docs.x.ai/grok-bot/get-started) · [FAQ](https://docs.x.ai/grok-bot/faq) · [Approvals, security, and privacy](https://docs.x.ai/grok-bot/approvals-security-and-privacy) · [Product](https://x.ai/bot)

Grok Bot is a **standalone SpaceXAI/Cursor agent app** with a persistent cloud computer. It is **not** the Grok model picker inside the Cursor IDE.

Related: [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md) (Cloud Agents in Cursor vs this product).

---

## Eligibility checklist (this machine)

| Check | Expected | Verified 2026-08-12 |
| --- | --- | --- |
| Plan | SuperGrok Heavy, Cursor Ultra, or Teams Premium | Cursor `stripeMembershipType` = **ultra**, `stripeSubscriptionStatus` = **active** |
| Privacy | Not Legacy Privacy Mode; cloud storage required | `newPrivacyMode2.privacyMode` = **PRIVACY_MODE_NO_TRAINING** |
| Platform | macOS Apple silicon / Intel, Windows, or iOS 18+ | macOS arm64 (Apple silicon) |
| App | Grok Bot desktop app | `/Applications/Grok Bot.app` **0.16.0** (`com.anysphere.sand`) |
| Sign-in | Cursor account | Signed in as Aaron Culich |
| First Bot | Created in app | **Call Coach** (suggested teammate) |
| Local execution | Ask every time / Never allowed | Verified **Ask every time** |
| Auto-review | On + narrow Require Approval rules | Toggle **ON**; add rules from checklist below if empty |

Re-check privacy in the dashboard if the app refuses to start:  
[cursor.com/dashboard/settings?openPrivacy=true](https://cursor.com/dashboard/settings?openPrivacy=true)

Helper: `cursor/scripts/grok-bot-setup.sh`

### Verified first-task result (2026-08-12)

Call Coach returned this summary from [get-started](https://docs.x.ai/grok-bot/get-started) (read-only; no third-party sign-in):

1. **Plan:** SuperGrok Heavy, Cursor Ultra, or Cursor Teams Premium; Cursor sign-in; Legacy Privacy Mode unsupported.
2. **App + target:** Desktop macOS/Windows (no Linux desktop); iOS companion; need an app/site for real work.
3. **Install:** Download from the access page → Applications / installer → open.
4. **Sign in:** Get started / Sign in with Cursor → browser auth → return to app.
5. **Create Bot:** Suggested teammate or custom name + primary job + description.

Note: Call Coach’s default Zoom/Granola onboarding can race with other tasks. Prefer a custom read-only Bot (e.g. Docs Scout) for docs-only work, or explicitly tell the Bot to ignore connectors.

---

## Install (already done here)

1. Download Apple silicon DMG from  
   `https://downloads.cursor.com/sand/stable/darwin-arm64/0.16.0/Grok_Bot_0.16.0.dmg`  
   or the chooser at [cursor.com/bot/onboarding](https://cursor.com/bot/onboarding).
2. Open the DMG → copy **Grok Bot.app** to `/Applications`.
3. Clear quarantine if Gatekeeper blocks first open:  
   `xattr -dr com.apple.quarantine "/Applications/Grok Bot.app"`
4. Launch: `open -a "Grok Bot"`

Updates: automatic, or **Settings → Beta → Check for Updates**.

---

## Configure (in the Grok Bot app)

Do these after the welcome / Cursor sign-in flow completes.

### 1. Sign in

1. **Get started** → finish browser auth with the same Cursor account (SSO if org requires it).
2. Answer the tools questionnaire (suggestions only; does not connect tools).
3. Wait for cloud computer setup → **Meet a future teammate**.

### 2. Create first Bot

Suggested teammate, or **Create your own**:

| Field | Example |
| --- | --- |
| Name | Piper |
| Job | Product performance |
| Description | Investigate product-performance questions using our observability tools. Do not change production systems or send external messages without approval. |

Standing boundaries belong in the Bot description.

### 3. Plugins

**Settings → Plugins** — install connectors for tools you trust; prefer connectors over raw browser when available.

### 4. Auto-review (recommended defaults)

**Settings → General → Auto-review**

Add narrow rules (Require Approval wins if both match):

- **Require Approval** before sending any external email.
- **Require Approval** before changing a production dashboard.
- **Require Approval** before publishing, deleting, purchasing, or changing permissions.

Avoid broad “allow everything in the browser” rules.

### 5. Local computer execution

**Settings → General → Agent → Execution on Local Computer**

- Default: **Ask every time**
- Prefer **Never allowed** until you have a specific local-file reason  
  (cloud computer still works either way)

### 6. Skills vs routines

- **Skill** = how to perform a task  
- **Routine** = skill assigned to a Bot on a schedule/event  

Test as a one-off before scheduling. **Teach a task** (when available) records up to 10 minutes of browser workflow into a draft skill.

---

## First task (read-only)

Paste into your new Bot. Adjust the URL/tool names to match your stack.

```text
Open https://docs.x.ai/grok-bot/get-started in the Agent Computer browser.
Summarize the install prerequisites and the first three setup steps in 5 bullets.
Do not sign into any third-party sites.
Do not change any settings, files, or dashboards.
Do not send messages or emails.
If anything requires authentication, CAPTCHA, or approval, stop and ask me.
```

### When login / 2FA appears

1. Open **Agent Computer** from the conversation.
2. Take control.
3. Enter password / passkey / 2FA / CAPTCHA yourself.
4. Return control to the Bot.
5. **Never paste secrets into ordinary chat.**

### Approvals UI

- Desktop: **Allow once** / **Deny** / **Always allow**
- iPhone: **Approve once** / **Deny**

---

## Security notes

- All Bots on the account share **one** cloud computer (files, browser sessions, logins). Separate Bots are **not** a security boundary.
- Closing the laptop does not stop cloud work.
- When finished with a project: pause routines, sign out of sites on the shared computer, revoke connectors, remove sensitive `/workspace` files.

Support: [hi@cursor.com](mailto:hi@cursor.com) · [Bug Reports](https://forum.cursor.com/c/support/bug-report/6) · [Forum announcement](https://forum.cursor.com/t/introducing-grok-bot/168053)

---

## Sources

- [Grok Bot product](https://x.ai/bot)
- [Get started](https://docs.x.ai/grok-bot/get-started)
- [FAQ](https://docs.x.ai/grok-bot/faq)
- [Approvals, security, and privacy](https://docs.x.ai/grok-bot/approvals-security-and-privacy)
- [Introducing Grok Bot (forum)](https://forum.cursor.com/t/introducing-grok-bot/168053)
