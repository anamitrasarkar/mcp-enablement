# Demo Flow — Slack + Agentforce via Custom MCP

### Click-by-click runbook with talk tracks

**Duration:** ~8–10 minutes
**Audience:** Business + IT leaders, Thursday
**Persona:** Jennifer Hynes, Senior AE, 9 minutes before her 11 am renewal call with Omega, Inc.

Each step has three parts: **SHOW** (what to click / type), **SAY** (exact talk track), **POINT** (what to physically point at on screen).

---

## Before you walk in — the setup check

| Window | State |
|---|---|
| **Slack** | DM with Slackbot open, empty message box, workspace sidebar visible |
| **Salesforce** | Omega, Inc. Account record loaded in a browser tab (one more tab logged into Setup → Agents, kept in background) |
| **Terminal 1** | MCP server running, visible log line `[agentforce-mcp] ready on :3000` |
| **Terminal 2** | Claude Code open, cursor ready for input |
| **Projection** | Slack is the active window |

Smoke-test both paths against **Acme Partners** 10 minutes before. If anything fails, see Section 9 of `demo-script.md`.

---

## Step 1 — Open on Jennifer's reality (no clicks yet)

**SHOW:** Nothing — stand up, look at the room.

**SAY:**
> *"Meet Jennifer. Senior AE. In nine minutes she has a renewal call with Omega, Inc. The last conversation was six weeks ago. There was a budget thread, a case her CSM filed, a new contact. All of it is in Salesforce. **None of it is in her head.** She's in Slack. Watch what she does."*

---

## Step 2 — Show Slack as her workspace

**SHOW:** Slack is already projected. Make the Slackbot DM the active pane.

**SAY:**
> *"This is Slack. This is where Jennifer already lives. She isn't going to open Salesforce. She isn't opening a new tool. She's doing what she already does — asking a question."*

---

## Step 3 — Jennifer types her Slack prompt

**SHOW:** Click the Slackbot message box. Type **slowly** so the room can read along:
> `Give me a snapshot of the Omega, Inc. account — opportunities, cases, contacts.`

Press **Enter**.

**SAY** (while typing):
> *"She's not asking in any special syntax. No SQL. No field names. The way a human would ask."*

---

## Step 4 — Slackbot answers — the "today" win

**SHOW:** Slackbot's response fills the thread. Wait for it fully.

**POINT:** The reply content.

**SAY:**
> *"Three seconds. Salesforce data, in the channel she already lives in. **No training. No new tool. No tab-flipping.** For a sales team of 200 reps saving five minutes a day, that's two full headcount back on productive work."*

---

## Step 5 — Reveal how it's wired (the admin page)

**SHOW:** Switch Slack to the **workspace admin** view. Navigate to **Salesforce MCP Servers**.

**POINT:** The row showing `sobject-all` with status **Connected**.

**SAY:**
> *"This is the entire configuration. **One row.** One Salesforce MCP server, called `sobject-all`, registered by our workspace admin. From that moment on, Slackbot knew how to call Salesforce. Zero per-user setup. That's the pattern we're going to build on."*

---

## Step 6 — Frame the gap

**SHOW:** Keep the admin page visible.

**SAY:**
> *"`sobject-all` is Salesforce's generic SObject bridge. It's great for raw record access. But watch — it does **not** apply Trust Layer masking. It does **not** retrieve free-text custom fields like Call Notes through a governed action. It does **not** produce a consistent, curated markdown format you can design once and ship everywhere. For simple lookups it's perfect. For the **governed experience** we need, we have to add one more thing to this page."*

---

## Step 7 — Switch to Claude Code to preview the governed path

**SHOW:** Switch projection to **Terminal 2 (Claude Code)**.

**SAY:**
> *"Our Salesforce team already built an Agentforce agent called **AccountSummaryAgent**. I'm about to call it — not from Slack yet, from a developer tool called Claude Code — because that's the fastest way to show you what the governed Slack experience will look like once we add the second MCP server to that admin page."*

---

## Step 8 — Type the Claude Code prompt

**SHOW:** In the Claude Code prompt, type:
> `Summarize the Omega, Inc. account using Agentforce.`

Press **Enter**.

**SAY** (while it runs):
> *"Same account Jennifer just asked about in Slack. Same question, different wording. Watch the output."*

---

## Step 9 — The governed response arrives — moment one

**SHOW:** The markdown brief fills the terminal. Scroll to the **Call Notes** section.

**POINT:** The blockquote with the $3M money market / 50bps / 11-year relationship passage.

**SAY:**
> *"**This block.** Her CSM typed this in Salesforce three weeks ago. Jennifer has never seen it. The agent didn't make it up — it called a custom Apex action that reads a custom field called `Call_Notes__c`, and formatted the passage as a markdown blockquote. Now she's walking into a renewal call knowing there's a pricing exception pending for a 50bps competitor offer."*

---

## Step 10 — The governed response — moment two

**SHOW:** Scroll up slightly to the **Company Info** section.

**POINT:** The `Website: URL_Redacted` line.

**SAY:**
> *"**This.** Salesforce's Trust Layer just masked a URL field on the way out. **We didn't configure Claude Code to do that. We didn't configure the MCP server to do that.** The policy lives inside Salesforce. **Every channel that reaches this agent inherits it automatically.** Change the policy once, every AI tool obeys."*

---

## Step 11 — Confirm the agent actually ran

**SHOW:** Switch to **Terminal 1 (MCP server)**.

**POINT:** The `[agentforce-mcp] session started {"sessionId":"019d..."}` log line.

**SAY:**
> *"That's the MCP server logging the Agent API session it just started on Jennifer's behalf. OAuth login, session open, prompt sent, response received, session closed. **Two hundred fifty lines of Node code.** That's the entire translator."*

---

## Step 12 — Ground truth check in Salesforce

**SHOW:** Switch projection to the **Salesforce browser tab** parked on **Omega, Inc.**'s Account record. Scroll to the **Call Notes** field.

**POINT:** The exact text matching what Claude Code just showed — the money-market passage.

**SAY:**
> *"The agent didn't invent that. **This is the record.** The agent's job is to read it, apply policy, format it, hand it back. Fix the record here — the next Slack message gets the fix. **No stale copies. No separate data store. One source of truth.**"*

---

## Step 13 — Walk back to the Slack admin page — make the ask concrete

**SHOW:** Switch back to Slack → the **Salesforce MCP Servers** admin page.

**POINT:** The current `sobject-all` row. Then point at the empty space below it.

**SAY:**
> *"Here's the ask, made simple. **We register our custom MCP server on this page.** Same shape as the `sobject-all` row. Name, HTTPS URL, description, bearer token for auth. From that moment on, Jennifer's **same prompt in Slack** — unchanged — gets the governed Agentforce response you just saw in Claude Code. **Call Notes, Trust Layer masking, consistent format — in Slack.**"*

---

## Step 14 — Show what adding it looks like (optional, 30 seconds)

**SHOW:** Click **Add Server** (or the equivalent button). Walk through the form fields without actually submitting:
- Name: `agentforce-account-summary`
- URL: `https://<slug>.trycloudflare.com/mcp`
- Description: *Returns a governed markdown Account summary via the Account Summary Agentforce agent.*
- Organization: same as `sobject-all`
- Who can use: Everyone

**SAY:**
> *"Four fields. Two minutes once we have a stable public URL. For the URL we use Cloudflare's tunnel — a one-command public HTTPS front door to our MCP server. **The technical scope of this change is small.** The scope of what it unlocks is not."*

Click **Cancel** / close the form without saving.

---

## Step 15 — Where this goes (Agent Studio brief view)

**SHOW:** Switch to the Salesforce Setup → Agents tab (background tab). Click into **Account Summary Agent**. Show **Topics** and **Actions**.

**POINT:** The list of actions.

**SAY:**
> *"This is where the agent lives. Topics are what it can talk about. Actions are what it can do. **Every new agent your Agentforce team ships here becomes a new capability** — for Jennifer in Slack, for your developers in Claude Code, for whatever AI tool the business picks up next. Add an action, change `SF_AGENT_ID`, done."*

---

## Step 16 — The close

**SHOW:** Back to the Slack admin page, so `sobject-all` is on screen with imagined second row below.

**SAY** (slowly, do not rush):
> *"Jennifer's story is every seller's story. Every CSM's story. Every service rep's story. Every one of them lives in Slack, Teams, Outlook, a browser, a Zoom — not in Salesforce. **Agentforce is a great agent runtime. MCP is how every other AI tool in the business reaches it, with governance intact.**"*

Pause.

> *"The ask: fund the custom MCP server as a shared product — one instance per environment. Add it to the admin page where `sobject-all` already lives. From that moment forward, every new agent your Agentforce team ships becomes a new capability — in Slack, in Claude Code, in Bedrock, on day one. **Zero per-tool integration work.**"*

Stop. Let it land.

---

## Quick-reference card (for a cheat sheet on your desk)

| # | Pane | Action | One line to say |
|---|---|---|---|
| 1 | — | Stand up | "Meet Jennifer. 9 minutes before a renewal call." |
| 2 | Slack | Make it the active window | "This is where she lives." |
| 3 | Slack DM | Type the snapshot prompt | "She asks like a human." |
| 4 | Slack reply | Wait, point at it | "Three seconds. No tab-flipping." |
| 5 | Slack admin | Open MCP Servers page | "One row. One admin action." |
| 6 | Same page | Point at the gap | "No Trust Layer. No Call Notes. No consistent format." |
| 7 | Claude Code | Switch | "Fastest way to show you the governed version." |
| 8 | Claude Code | Type Agentforce prompt | "Same account. Same question." |
| 9 | Response | Point Call Notes | "Her CSM typed this. She's never seen it." |
| 10 | Response | Point URL_Redacted | "Trust Layer, applied automatically." |
| 11 | Terminal 1 | Point session log | "Agent ran. 250 lines of Node." |
| 12 | Salesforce | Point Call Notes field | "This is the record. One source of truth." |
| 13 | Slack admin | Point empty row below sobject-all | "Add our MCP here. Same shape." |
| 14 | Add Server form | Walk fields; cancel | "Four fields. Two minutes." |
| 15 | Agent Studio | Show agent | "Every new agent becomes a new Slack capability." |
| 16 | Back to Slack admin | Close | "Fund the universal remote." |

---

## If someone interrupts mid-flow

| Interruption | How to recover |
|---|---|
| *"Can we see this in Slack now?"* | *"Not yet — we need to put the custom MCP on that admin page first. Give me the green light; demo in Slack within a week."* |
| *"Why not use sobject-all for everything?"* | *"Great for raw data. For governed answers across every AI tool, you want the agent in the loop. The two coexist — one isn't replacing the other."* |
| *"Is this secure?"* | Three layers: Slack → MCP via bearer token. MCP → Salesforce via OAuth client-credentials. Agent runs as a configured Run-As user with FLS/sharing applied. All standard Salesforce security. |
| *"How much does this cost to run?"* | Two cost centers — client-side LLM tokens (our path is 3–8× more efficient than raw SOQL) and Salesforce Einstein Request credits (bundled with Agentforce licensing). |
| *"How long did this take to build?"* | 250 lines of Node. Half a day. The scope of the ask is operational funding, not engineering effort. |

Keep each answer under 15 seconds. Then say *"Happy to go deeper after"* and return to the next step.
