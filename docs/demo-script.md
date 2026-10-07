# Agentforce + Slack + Claude — Demo Script

### A 12-minute persona-led demo for a business + IT audience

**The persona:** *Jennifer Hynes, Senior Account Executive. 9 minutes before her 11 am renewal call with Omega, Inc.*

---

## 0 · Pre-Flight (do this 30 minutes before the room fills up)

### What you need in front of you

| Window | Purpose |
|---|---|
| Browser tab 1 | Slack workspace, open to a channel you can post in — ideally called `#demo-jennifer` or similar |
| Browser tab 2 | Salesforce org `trailsignup-...my.salesforce.com`, logged in, home page |
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

**Expose it publicly for Slack (one-time per demo):**
```bash
cloudflared tunnel --url http://localhost:3000
```
Copy the `https://<slug>.trycloudflare.com` URL. This is the URL Claude Tag in Slack will hit.

**Terminal tab 2 — Claude Code:**
```bash
cd ~/Projects/Salesforce/mcp-server-org
claude
```

**Slack — Claude Tag MCP registration (one-time per workspace):**
In your Slack admin, add the MCP server URL (`https://<slug>.trycloudflare.com/mcp`) to Claude Tag's MCP server list. Confirm Claude Tag can see the `get_account_summary` tool. If you've not set up Claude Tag before, use `/install-slack-app` from the Claude Code CLI.

### Smoke tests (do these before the audience arrives)

**Test 1 — Claude Code path (dev-facing):**
In terminal tab 2, type:
> Summarize the Acme Partners account using Agentforce.

Expect a markdown brief under 5 seconds. (A deliberately different account from the live demo — a passing smoke test proves the wiring independently of the Omega run.)

**Test 2 — Slack path (business-facing):**
In the Slack channel, type:
> @Claude Give me a snapshot on Acme Partners.

Expect the same brief in Slack within 5 seconds.

If either fails, see **Section 9 — Failure Recovery** before continuing.

---

## 1 · The 60-Second Set-Up — Introduce Jennifer (do not touch a keyboard)

Stand up. Make eye contact. Say:

> *"I want you to meet Jennifer. She's a Senior AE at a mid-market SaaS company. She has back-to-back customer calls today and she lives in Slack. In nine minutes she has a renewal call with Omega, Inc. The last conversation was six weeks ago. There was a budget conversation, a case her CSM filed, and a new contact added. All of it is in Salesforce. **None of it is in her head.**"*

Pause.

> *"Today, Jennifer's playbook is: open Salesforce, type the account, click into the record, open Opportunities in a new tab, flip to Cases, hunt for contacts, dig through Chatter. Three minutes gone, half the signals missed, and she's still in a browser instead of in the Slack thread where her SDR is pinging her. I'm going to show you what Jennifer's **next** nine minutes look like — using the AI tools your business already pays for, and the Agentforce agent your Salesforce team already built."*

---

## 2 · Act One — Jennifer in Slack (2 minutes)

**Switch to the Slack window.** Project it. Make it big.

Say:
> *"This is Jennifer's Slack. She's already here. She's not opening Salesforce. Watch."*

**Type into the channel exactly:**
> @Claude Give me a snapshot on Omega, Inc. before my 11 am.

**What the audience sees:**
- Claude Tag thinks for 2–3 seconds
- A clean markdown brief appears in the thread
- Company Info, **Call Notes** (from last touchpoint), Top Open Opportunity, Recent Cases, Key Contacts, Closed-Won Revenue

**When the brief appears, point to the Call Notes section** and say:
> *"That line right there — her CSM typed those call notes in Salesforce three weeks ago. Jennifer has never seen them. Now she's walking into a renewal call with that context in hand, and she never left Slack."*

Then point to the **Website** field (which will read `URL_Redacted`) and say:
> *"And notice this. Salesforce's Trust Layer just masked a field on the way out. **Jennifer didn't configure that. Slack didn't configure that. Claude didn't configure that.** The policy lives inside Salesforce. Every channel that reaches this agent inherits it."*

---

## 3 · Act Two — The Four Pieces (2 minutes)

**Switch to `docs/value-proposition.md`** (or the PDF). Project the diagram.

Walk it, don't read it:

- *"Four pieces. Slack — where Jennifer is. Claude — the AI brain, lives in Slack as Claude Tag. The MCP server — the universal remote. And Salesforce, where the Agentforce agent and the data live."*
- *"Slack is where the human is. Salesforce is where the data is. The MCP server is the wire."*
- *"Six hops. Three protocols. One answer back. Under three seconds."*

**One line to anchor it:**
> *"The MCP server is a universal remote. One remote. One agent. Many front doors."*

---

## 4 · Act Three — The Developer View (2 minutes)

**Switch to Terminal tab 2 (Claude Code).** Project it.

Say:
> *"Jennifer uses Slack. But what if you're a developer? Or an engineer building a workflow in Bedrock? Or an IT ops team wiring this into Copilot Studio? Same backend. Different front door."*

**Type into Claude Code:**
> Summarize the Omega, Inc. account using Agentforce.

**What the audience sees:**
- A tool-use card for `get_account_summary`
- The same markdown brief Jennifer saw in Slack

Point to the MCP server terminal (tab 1). It shows:
```
[agentforce-mcp] session started {"sessionId":"019d..."}
```

Say:
> *"Same server. Same agent. Same governance. Different human, different tool. That is the business case in one slide — **build the capability once, every surface the business already uses picks it up.**"*

---

## 5 · Act Four — The Governance Proof (2 minutes)

Say:
> *"Let me show you why we didn't just let Claude hit the Salesforce REST API directly."*

**In Claude Code, type:**
> Summarize the Omega, Inc. account by running SOQL queries directly, not using Agentforce.

**What the audience sees:**
- Four or five SOQL tool calls in sequence
- A hand-assembled summary
- **The Website field now shows the raw URL** — no masking

**Pull up this table on screen** (from `docs/agentforce-mcp-enablement.pdf` page 4, or copy from below):

| Metric | Agentforce path | Raw SOQL path |
|---|---:|---:|
| Client-side tokens | ~150 | ~1,190 |
| Governance applied | ✅ (URL redacted) | ❌ (URL leaked) |
| Lines of client code | 0 | Many (per client) |
| Works for every AI surface | ✅ (if MCP-aware) | ❌ (bespoke per client) |

Say, slowly:
> *"Both answers are 'correct'. Only one is **enterprise-safe, repeatable, and reusable**. That's the difference between a developer poking at an API and a product the business can scale on."*

---

## 6 · Act Five — The Extensibility Pitch (90 seconds)

Say:
> *"Everything you've seen runs on my laptop. Three ways this scales to the rest of the business."*

**1. New AI surfaces, zero per-surface work.**
> *"Cursor, Bedrock Agents, Vertex, Copilot Studio — all speak MCP. Point them at the same URL. Zero new code. Jennifer in Slack, your SDR in Cursor, your workflow bot in Bedrock — all calling the same Agentforce agent."*

**2. Public reach, one command.**
> *"The URL Slack is calling right now came from this."*
Show Terminal 1's cloudflared output.
> *"One command. One public HTTPS URL. Add a bearer token for prod. Done."*

**3. New agents, one env var.**
> *"To expose the HR agent, the service agent, the procurement agent — change `SF_AGENT_ID` or add a second tool to this MCP server. One deploy. Every AI surface in the business picks it up on the next call."*

---

## 7 · Close — The Ask (45 seconds)

Say, slowly, do not rush this:

> *"Jennifer's story is every seller's story. Every CSM's story. Every service rep's story. Every one of them lives in Slack, Teams, Outlook, a browser, a Zoom. Not in Salesforce. **Agentforce is a great agent runtime. MCP is how every other AI tool in the business reaches it.**"*

Pause.

> *"The ask: treat this MCP server as a product, not a prototype. Fund one shared instance per environment. Publish an internal catalog of exposed Agentforce agents. Make this the default path by which every AI tool reaches Salesforce. Every new agent your Agentforce team ships becomes a new capability — for Jennifer in Slack, for your developers, for your automations — on day one, with zero per-tool integration work."*

Stop. Let it land.

---

## 8 · Expected Q&A (prep these answers)

> **"Is data leaving Salesforce?"**
> Only the agent's final answer leaves — and only to the client that asked. Salesforce data stays in Salesforce. The MCP server doesn't persist anything.

> **"Where does Slack fit in the trust story?"**
> Slack is just the surface Jennifer types into. The message is passed to Claude Tag; Claude calls the MCP server; the MCP server calls Salesforce. Slack never sees Salesforce data except as a rendered reply in Jennifer's thread. If you've approved Claude Tag for your Slack workspace, you've already approved the trust boundary.

> **"How is this secured over the internet?"**
> Four layers: (1) Slack → Claude Tag runs over Slack's native auth. (2) Claude Tag → MCP server protected by a bearer token. (3) MCP server → Salesforce via OAuth Client-Credentials — short-lived tokens, no stored passwords. (4) The agent runs as a Salesforce user whose permission set controls what records it can see.

> **"What if the agent gives a wrong answer?"**
> The agent is grounded in CRM records. If a record is wrong in Salesforce, the agent reflects that. Fix the record in Salesforce and the next call is correct. There is no "hallucinated" view of the data.

> **"How much does this cost?"**
> Two cost centers: (1) **Client-side LLM tokens** — Claude's bill. Our MCP path is 3–8× more token-efficient than hand-querying Salesforce. (2) **Einstein Request credits** — Salesforce bills per agent turn against your bundled quota. On Agentforce licensing, these are already paid for.

> **"What's the catch?"**
> The agent only knows what you've taught it. Ask the Account Summary agent about HR data, it will politely decline. That's a feature.

> **"How long did this take to build?"**
> About 250 lines of TypeScript for the MCP server. Half a day. Deployed in minutes.

> **"Can we run multiple agents on one MCP server?"**
> Yes — each becomes a separate tool name. Same server, same deploy. Jennifer's `@Claude` command list grows every time your Agentforce team ships a new agent.

> **"What if Slack is down?"**
> The developer can still reach the agent via Claude Code (we just showed it). The agent is still reachable via any other MCP client. The only thing that fails is one of the many front doors.

---

## 9 · Failure Recovery (if the live demo breaks)

### If Slack says Claude Tag can't reach the tool
The Cloudflare tunnel URL changed since you registered it. Re-copy the URL from Terminal tab 1 and update Claude Tag's MCP server list. For prod, use a stable `cloudflared tunnel --config` with a fixed hostname.

### If Claude Code says `Error: Start session failed: 400 ... Invalid user ID`
The MCP server's `.env` is wrong or stale. Check `SF_AGENT_ID`, `SF_CONSUMER_KEY`, `SF_CONSUMER_SECRET`, `SF_MY_DOMAIN_URL`. Restart in Terminal tab 1.

### If Claude hangs for 60 seconds then times out
The Run-As user on the External Client App can't run the agent. In Salesforce: Setup → **External Client Apps** → open the ECA → confirm the Run-As user has the Agentforce permission set. Reactivate the ECA.

### If the MCP server shows `OAuth token request failed`
The consumer key/secret is wrong, or the ECA's OAuth policies don't allow Client Credentials. Regenerate, redeploy.

### If **everything** fails and you need a graceful out
Pivot to the PDF (`docs/agentforce-mcp-enablement.pdf`) and walk Jennifer's story statically. Promise a follow-up demo and move on. **Do not debug live** — you lose the room.

---

## 10 · After the Demo — Follow-Ups

Send these three artifacts within an hour of leaving the room:

1. **`docs/value-proposition.md`** (or the PDF) — the one-pager for exec forwarders. Jennifer's story is the hook; the diagram is the proof.
2. **`docs/agentforce-mcp-enablement.pdf`** — the detailed enablement doc for IT reviewers. Trust Layer evidence; token math; architecture.
3. **A calendar hold** with the two people in the room most likely to fund this. Title: *"Agentforce MCP — scope + sponsor."* Due within 10 business days.

Momentum is cheap right after a successful demo. Spend it.
