# Agentforce + Slack + Claude — Demo Script

### A 12-minute persona-led demo for a business + IT audience

**The persona:** *Jennifer Hynes, Senior Account Executive. 9 minutes before her 11 am renewal call with Omega, Inc.*

**The story in one line:** *Today she can get Salesforce data in Slack. Tomorrow she can get a governed Agentforce agent's answer — the same way — from Slack, Claude Code, or any AI tool the business picks up next.*

---

## 0 · Pre-Flight (do this 30 minutes before the room fills up)

### What you need in front of you

| Window | Purpose |
|---|---|
| Browser tab 1 | Slack workspace, open to a DM with **Slackbot** |
| Browser tab 2 | Salesforce org (`trailsignup-...my.salesforce.com`), logged in, home page |
| Terminal tab 1 | MCP server running |
| Terminal tab 2 | Claude Code (CLI) in the project directory |
| Terminal tab 3 | Idle, for ad-hoc SOQL via `sf` if the Q&A gets technical |

### Boot sequence

**Terminal tab 1 — MCP server:**
```bash
cd ~/Projects/Salesforce/mcp-server-org/mcp-server
npm run build && npm start
```
Expect: `[agentforce-mcp] ready on :3000 (POST /mcp) [NO AUTH]`

**Terminal tab 2 — Claude Code:**
```bash
cd ~/Projects/Salesforce/mcp-server-org
claude
```

**Slack — confirm the `sobject-all` MCP server is still registered.** Workspace Admin → Salesforce MCP Servers → confirm `sobject-all` shows **Connected**. You already have this working.

### Smoke tests (do these before the audience arrives)

**Test 1 — Slack path (business-facing, via `sobject-all`):**
In the Slackbot DM, type:
> Give me a snapshot of the Acme Partners account — open opportunities, recent cases, and key contacts.

Expect a response within ~5 seconds.

**Test 2 — Claude Code path (dev-facing, via your custom MCP + Agentforce):**
In terminal tab 2, type:
> Summarize the Acme Partners account using Agentforce.

Expect a markdown brief under 5 seconds.

**Why Acme Partners for smoke tests:** different account from the live demo (Omega) — a passing smoke test proves wiring independently.

If either fails, see **Section 9 — Failure Recovery**.

---

## 1 · The 60-Second Set-Up — Introduce Jennifer (do not touch a keyboard)

Stand up. Make eye contact. Say:

> *"I want you to meet Jennifer. She's a Senior AE at a mid-market SaaS company. She has back-to-back customer calls today and she lives in Slack. In nine minutes she has a renewal call with Omega, Inc. The last conversation was six weeks ago. There was a budget conversation, a case her CSM filed, and a new contact added. All of it is in Salesforce. **None of it is in her head.**"*

Pause.

> *"Today, Jennifer's playbook is: open Salesforce, type the account, click into the record, open Opportunities in a new tab, flip to Cases, hunt for contacts, dig through Chatter. Three minutes gone, half the signals missed, and she's still in a browser instead of in the Slack thread where her SDR is pinging her. I'm going to show you two things. First, what Jennifer can do in Slack **today** with the AI tools your business already pays for. Then I'll show you where this story goes next — and why that matters strategically."*

---

## 2 · Act One — Jennifer in Slack TODAY (2 minutes)

**Switch to the Slack DM with Slackbot.** Project it. Make it big.

Say:
> *"This is Jennifer's Slack. She's already here. She's not opening Salesforce. Watch."*

**Type into the Slackbot DM exactly:**
> Give me a snapshot of the Omega, Inc. account — open opportunities, recent cases, key contacts, and any call notes.

**What the audience sees:**
- Slackbot thinks for a moment
- A response appears: company data, opportunities (if any), cases, contacts
- All pulled live from Salesforce

**Point to the Slack admin screen (brief flash on screen) and say:**
> *"This is working because her workspace admin registered a **Salesforce MCP server** called `sobject-all` with Slackbot. Slack now knows how to talk to Salesforce in natural language. One admin action. No per-user setup. Jennifer never saw a Salesforce URL."*

Pause.

> *"That's **win number one** — Salesforce data, in the channel she already lives in, in natural language. **No training. No new tool. No tab-flipping.** For a sales team of 200, if each rep saves five minutes a day, that's two full headcount back on productive work."*

---

## 3 · Act Two — The Four Pieces, and Where the Story Goes Next (2 minutes)

**Switch to `docs/value-proposition.md`** (or the PDF). Project the diagram.

Walk it, don't read it:

- *"Four pieces. **Slack** — where Jennifer is. **Claude** or Slackbot — the AI brain in the channel. **The MCP server** — the universal remote that lets any AI tool talk to Salesforce. And **Salesforce + Agentforce**, where the agent and the data live."*
- *"What you just saw uses `sobject-all` — Salesforce's generic Slack-to-SObject bridge. It's a great first win."*
- *"But look at this box here — the Agentforce agent. That's where **governed reasoning** lives. Trust Layer. Custom actions. Call Notes retrieval. Approval workflows. **The ask today is: let's wire our custom Agentforce agents into the same pattern — so Jennifer, and every AI tool after Slack, gets the governed experience, not just the raw data.**"*

**One line to anchor it:**
> *"Build the agent once. Every surface the business already uses picks it up."*

---

## 4 · Act Three — The Agentforce Experience (via Claude Code) (3 minutes)

**Switch to Terminal tab 2 (Claude Code).** Project it.

Say:
> *"Let me show you what the governed Agentforce experience looks like. Same question, same account. Different path — through our custom MCP server, into the AccountSummaryAgent we built in Agentforce."*

**Type into Claude Code:**
> Summarize the Omega, Inc. account using Agentforce.

**What the audience sees:**
- A tool-use card for `get_account_summary`
- A clean markdown brief with Company Info, **Call Notes**, Top Open Opp, Recent Cases, Key Contacts, Closed-Won Revenue

**When the brief appears, point to the Call Notes section** and say:
> *"That block right there — her CSM typed those call notes in Salesforce three weeks ago. $3M money market, competitor offered 50bps higher, 11-year relationship, pricing exception pending. **Jennifer has never seen this.** Now she's walking into a renewal call with that context in hand."*

Then point to the **Website** field (which reads `URL_Redacted`) and say:
> *"And notice this. Salesforce's **Trust Layer** just masked a field on the way out. **We didn't configure Claude Code to do that. We didn't configure the MCP server to do that.** The policy lives inside Salesforce, and every channel that reaches this agent inherits it automatically. **That is the business case in one data point** — change the policy once in Salesforce, every AI tool obeys."*

**Then compare — don't rush this:**

> *"The Slack view I showed you first gave Jennifer **data**. The Agentforce view gives her an **answer** — curated, governed, consistent, with free-text call notes that would have taken her minutes to hunt down in Chatter. Both have their place. **The strategic unlock is bringing this second view — the governed one — into Slack too, so Jennifer gets it without leaving the channel she already lives in."*

---

## 5 · Act Four — The Choice, Made Concrete (90 seconds)

**Pull up this table on screen** (from `docs/agentforce-mcp-enablement.pdf` page 4, or recreate from below):

| Dimension | Slack + `sobject-all` (today) | Slack + custom MCP + Agentforce (next) |
|---|---|---|
| Who built it | Salesforce ships it as a connector | We build the Agentforce agent once |
| What Jennifer gets | Raw record data in a reply | Governed markdown brief with free-text call notes |
| Trust Layer / data masking | ❌ Not applied | ✅ Applied automatically |
| Consistent output format | ❌ Slackbot formats on the fly | ✅ Same template every time |
| Reuse in other AI tools (Claude Code, Bedrock, Cursor) | ❌ Slack-only | ✅ Every MCP client works |
| Cost to add a new capability | File a request with Salesforce | We ship an Agentforce agent and env-var it in |

Say, slowly:
> *"Neither view is wrong. The first one is a great starting point. **The second one is a product the business can scale on.** The ask is to invest in path two, so every new agent your Agentforce team builds becomes a new capability in Slack, in Claude Code, in Bedrock, in Cursor, on the day it ships."*

---

## 6 · Act Five — The Extensibility Pitch (90 seconds)

Say:
> *"Everything you've seen runs on my laptop. Three ways this scales to the rest of the business."*

**1. New AI surfaces, zero per-surface work.**
> *"Cursor for engineers, Bedrock Agents for workflow automation, Vertex for GCP teams, Copilot Studio for IT ops — all speak MCP. Point them at the same URL. Zero new code. Jennifer in Slack, your SDR in Cursor, your workflow bot in Bedrock — all calling the same Agentforce agent, with the same governance."*

**2. Public reach, one command.**
> *"To bring this governed experience **into Slack**, we expose the MCP server at a public HTTPS URL — one command with Cloudflare, add a bearer token, add the URL to the same Slack admin page where `sobject-all` already lives."*

**3. New agents, one env var.**
> *"To expose the HR agent, the service agent, the procurement agent — change `SF_AGENT_ID` or add a second tool to this MCP server. One deploy. Every AI surface in the business picks it up on the next call."*

---

## 7 · Close — The Ask (45 seconds)

Say, slowly, do not rush this:

> *"Jennifer's story is every seller's story. Every CSM's story. Every service rep's story. Every one of them lives in Slack, Teams, Outlook, a browser, a Zoom. Not in Salesforce. **Agentforce is a great agent runtime. MCP is how every other AI tool in the business reaches it — with governance intact.**"*

Pause.

> *"The ask: fund the custom Agentforce MCP server as a shared product — one instance per environment. Publish an internal catalog of exposed Agentforce agents. Add it to the same Slack admin page where `sobject-all` lives today. From that moment forward, every new agent your Agentforce team ships becomes a new capability — for Jennifer in Slack, for your developers, for your automations — on day one, with zero per-tool integration work."*

Stop. Let it land.

---

## 8 · Expected Q&A (prep these answers)

> **"Why not just stick with `sobject-all`?"**
> It gives you data access, not agent reasoning. No Trust Layer masking. No consistent output format. No free-text call notes retrieval. No reusable Apex actions. For simple record lookups it's fine. For the governed, reusable experience, you want the agent in the loop.

> **"Is data leaving Salesforce?"**
> Only the agent's final answer leaves — and only to the client that asked. Salesforce data stays in Salesforce. The MCP server doesn't persist anything.

> **"Where does Slack fit in the trust story?"**
> Slack is the surface Jennifer types into. For `sobject-all`, Slack is calling Salesforce directly through a native integration your admin approved. For our custom MCP path, Slack would call our MCP server via a bearer-authenticated HTTPS URL; the server then calls Salesforce via OAuth. Same trust boundary, more layers of policy.

> **"How is this secured over the internet?"**
> Three layers: (1) Slack → MCP server via bearer token on a Cloudflare tunnel. (2) MCP server → Salesforce via OAuth Client-Credentials — short-lived tokens, no stored passwords. (3) The agent runs as a Salesforce user whose permission set controls record visibility.

> **"What if the agent gives a wrong answer?"**
> The agent is grounded in CRM records. If a record is wrong in Salesforce, the agent reflects it. Fix the record; next call is correct. No hallucinated view of the data.

> **"How much does this cost?"**
> Two cost centers: (1) **Client-side LLM tokens** — Claude's bill (3–8× more efficient on our MCP path vs raw SOQL). (2) **Einstein Request credits** — Salesforce bills per agent turn. On Agentforce licensing, already paid for.

> **"What's the catch?"**
> The agent only knows what you've taught it. Ask the Account Summary agent about HR data, it will politely decline. That's a feature.

> **"How long did this take to build?"**
> About 250 lines of TypeScript for the MCP server. Half a day. Deployed in minutes.

> **"Can we run multiple agents on one MCP server?"**
> Yes — each becomes a separate tool name. Same server, same deploy. Jennifer's catalog grows every time your Agentforce team ships a new agent.

> **"Can we show this governed experience in Slack today, in this meeting?"**
> Not yet — the custom MCP server is on a laptop. Spinning up a public URL via Cloudflare is a one-liner; adding it to the Slack admin page takes two minutes. **Give me the green light and I'll demo it to this group within a week on a stable URL.**

---

## 9 · Failure Recovery (if the live demo breaks)

### If Slackbot doesn't respond to the sobject-all prompt
Workspace Admin → Salesforce MCP Servers → re-check `sobject-all` shows **Connected**. If it says anything else, click into it and reconnect.

### If Claude Code says `Error: Start session failed: 400 ... Invalid user ID`
The MCP server's `.env` is wrong or stale. Check `SF_AGENT_ID`, `SF_CONSUMER_KEY`, `SF_CONSUMER_SECRET`, `SF_MY_DOMAIN_URL`. Restart in Terminal tab 1.

### If Claude Code hangs for 60 seconds then times out
The Run-As user on the External Client App can't run the agent. In Salesforce: Setup → **External Client Apps** → open the ECA → confirm the Run-As user has the Agentforce permission set. Reactivate the ECA.

### If the MCP server terminal shows `OAuth token request failed`
The consumer key/secret is wrong, or the ECA's OAuth policies don't allow Client Credentials. Regenerate, redeploy.

### If **everything** fails and you need a graceful out
Pivot to the PDF (`docs/agentforce-mcp-enablement.pdf`) and walk Jennifer's story statically. Promise a follow-up demo and move on. **Do not debug live** — you lose the room.

---

## 10 · After the Demo — Follow-Ups

Send these three artifacts within an hour of leaving the room:

1. **`docs/value-proposition.md`** (or the PDF) — the one-pager for exec forwarders. Jennifer's story is the hook; the two-tier framing is the proof.
2. **`docs/agentforce-mcp-enablement.pdf`** — the detailed enablement doc for IT reviewers. Trust Layer evidence; token math; architecture.
3. **A calendar hold** with the two people in the room most likely to fund this. Title: *"Agentforce MCP in Slack — scope + sponsor."* Due within 10 business days.

Momentum is cheap right after a successful demo. Spend it.
