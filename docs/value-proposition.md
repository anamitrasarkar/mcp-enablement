# Agentforce Everywhere — Value Proposition

### A persona-led case for governed Salesforce agents in Slack and every other AI surface

---

## 1 · The Problem We're Solving — Jennifer's 10-Minute Window

**Meet Jennifer Hynes.** Senior Account Executive, mid-market SaaS, five years in the seat. Jennifer's calendar is a wall of back-to-back customer calls. Between a sync with Legal and a renewal pitch with **Omega, Inc.**, she has nine minutes. The last conversation with Omega was six weeks ago. There's a half-remembered mention of a budget freeze, a case her CSM filed, and a new contact added by a colleague. All of it is in Salesforce. None of it is in her head.

Jennifer's current playbook: open Salesforce, type the account name, click into the record, scroll to Related, open Opportunities in a new tab, flip to Cases, hunt for the contact list, dig into Chatter for notes. **Three minutes gone, half the signals missed, and she's still in a browser tab instead of in Slack where her team is waiting.**

Jennifer doesn't need a new AI tool. She needs the AI that already lives in Slack to **know how to talk to the governed Salesforce agent her team has built.** Today, Slack can reach Salesforce for raw data via the standard `sobject-all` connector — a solid first win. The next step — and the strategic ask here — is to put the **governed Agentforce agent** on the same path, so that Jennifer (and every AI tool the business picks up after Slack) gets consistent, policy-safe, free-text-aware answers from the same source of truth.

> *"Give me a snapshot on Omega, Inc. before my 11 am."*
>
> Three seconds later, in Jennifer's Slack: a tight markdown brief — company info, call notes from last touchpoint, top open opp, open case status, key contacts, closed-won total. Jennifer reads it, walks into the Zoom, opens the call with the renewal number her CSM filed last Tuesday. Omega hears "you're paying attention." The call lands.

---

## 2 · Architecture at a Glance — Two Tiers, One Target

Four things are in play, in order from **where the human is** to **where the data is**:

| # | Piece | Role in the story |
|---|---|---|
| 1 | **Slack** | Where Jennifer lives. The channel she's already in; the surface she doesn't need to be re-trained on. |
| 2 | **AI brain in Slack** | Slackbot today (routing to `sobject-all`); Claude or the same Slackbot via our MCP server tomorrow. |
| 3 | **The MCP server** (this project) | The translator between any AI client and the Agentforce agent. ~250 lines of Node. |
| 4 | **Agentforce + Salesforce** | The agent, its actions, its data, its governance — all inside the org. |

### Tier 1 — Today (what you can see live)

```
     JENNIFER (Slack DM with Slackbot)
                   │
                   │  "snapshot of Omega, Inc. — opps, cases, contacts"
                   ▼
          ┌─────────────────┐
          │  Slackbot AI    │
          │  (routes NL →   │
          │   tool calls)   │
          └────────┬────────┘
                   │ MCP (hosted by Salesforce)
                   ▼
          ┌─────────────────┐
          │  sobject-all    │   ← Salesforce-shipped generic
          │  MCP server     │     SObject bridge
          └────────┬────────┘
                   │ REST + SOQL
                   ▼
          ┌─────────────────┐
          │  Salesforce     │
          │  SObject data   │     Raw records come back.
          │  (no agent in   │     No Trust Layer. No curated
          │   the loop)     │     format. No agent reasoning.
          └─────────────────┘
```

### Tier 2 — The Ask (what Thursday is about)

```
                                            JENNIFER (Slack)
                                                   │
                                                   │  same natural question
                                                   ▼
                                           ┌────────────────┐
                                           │ Slackbot or    │
                                           │ Claude in Slack│
                                           └────────┬───────┘
                                                    │ MCP JSON-RPC
                                                    │ POST /mcp
                                                    ▼
   ┌──────────────┐           MCP JSON-RPC    ┌────────────────┐
   │ Claude Code  │ ─── POST /mcp ──────────► │  Agentforce    │ ◄── Cursor, Bedrock,
   │  (dev tool)  │ ◄── markdown reply ────── │  MCP server    │     Vertex, Copilot
   └──────────────┘                           │  (this project)│     Studio, future
                                              └────────┬───────┘     clients
                                                       │
                                              HTTPS over internet
                                                       │
                              ┌────────────────────────┼─────────────────────┐
                              │ SALESFORCE ORG         │                     │
                              │                        ▼                     │
                              │  ┌───────────────────────────────────────┐   │
                              │  │ 1) OAuth client-credentials           │   │
                              │  │    POST /services/oauth2/token        │   │
                              │  │    → short-lived access_token         │   │
                              │  └───────────────────────────────────────┘   │
                              │                 │                            │
                              │                 ▼ bearer token               │
                              │  ┌───────────────────────────────────────┐   │
                              │  │ 2) Agent API                          │   │
                              │  │    start session + send message       │   │
                              │  └───────────────────┬───────────────────┘   │
                              │                      │                       │
                              │                      ▼                       │
                              │  ┌───────────────────────────────────────┐   │
                              │  │ 3) AccountSummaryAgent                │   │
                              │  │    (Agentforce, aiAuthoringBundle)    │   │
                              │  │    "Call Get Account Summary action"  │   │
                              │  └───────────────────┬───────────────────┘   │
                              │                      │                       │
                              │                      ▼                       │
                              │  ┌───────────────────────────────────────┐   │
                              │  │ 4) AccountSummaryAction (Apex)        │   │
                              │  │    SOQL: Account, Opp, Case, Contact, │   │
                              │  │          Call_Notes__c                │   │
                              │  │    → governed markdown brief          │   │
                              │  │    (Trust Layer masks apply)          │   │
                              │  └───────────────────────────────────────┘   │
                              │                                              │
                              └──────────────────────────────────────────────┘
```

Think of it as a **universal remote control** for Salesforce agents. Today, Slack can turn on the TV. The ask is to put the agent on the remote, so pressing one button gives Jennifer — in Slack, in Claude Code, in anything that comes next — a governed, curated answer, not just raw data.

---

## 3 · How the Systems Are Connected — Flow Comparison

Follow the same natural-language question through both tiers.

### Tier 1 flow (today, via `sobject-all`)

| # | Hop | Protocol | What travels |
|---|---|---|---|
| 1 | **Jennifer → Slack** | Slack native | "snapshot of Omega, Inc." |
| 2 | **Slack → Slackbot AI** | internal | message routed to configured MCP servers |
| 3 | **Slackbot → `sobject-all`** | MCP (Salesforce-hosted) | parsed tool calls (describe, query, …) |
| 4 | **`sobject-all` → Salesforce REST + SOQL** | REST | raw records returned |
| ↩ | **Reply back** | Slackbot formats | plain-text or table reply in Jennifer's DM |

**What's missing:** no Agentforce agent in the loop → no Trust Layer masking, no custom actions, no Call Notes free-text retrieval, no consistent markdown template.

### Tier 2 flow (the ask, Slack + custom MCP + Agentforce)

| # | Hop | Protocol | What travels |
|---|---|---|---|
| 1 | **Jennifer → Slack** | Slack native | same question |
| 2 | **Slack AI → MCP server** | MCP (JSON-RPC over HTTPS, bearer-authenticated) | `tools/call: get_account_summary(account="Omega, Inc.")` |
| 3 | **MCP server → Salesforce OAuth** | form-urlencoded | `grant_type=client_credentials` → access_token |
| 4 | **MCP server → Agent API** | REST JSON + Bearer | start session, send message |
| 5 | **Agent → Apex invocable → SOQL** | internal | `AccountSummaryAction.execute(...)` reads Account/Opp/Case/Contact/`Call_Notes__c` |
| ↩ | **Reply back** | each layer unwraps | **governed markdown brief** — Trust Layer applied, Call Notes rendered — lands in Slack |

**Three structural properties that matter for IT:**

1. **Governance lives in Salesforce, not in the client.** Trust Layer masking, FLS, sharing rules, prompt policies — configured once in the org. Every channel (Slack, Claude Code, Bedrock) inherits them automatically on the Tier 2 path.
2. **The MCP server is stateless.** OAuth tokens cached in memory for ~25 min; one Agent API session per request, closed after reply. Kill the server; no data lost.
3. **No new Salesforce APIs invented.** Already-GA Salesforce Agent API + Client-Credentials OAuth. The only new code is ~250 lines of TypeScript in the MCP server.

---

## 4 · Extensibility — Where This Goes Next

Today Jennifer gets data in Slack via `sobject-all`. The ask is to put our Agentforce MCP server on the same Slack admin page, exposed at a public HTTPS URL. The exact same server, with no code changes, then extends in four directions:

1. **New AI surfaces, zero per-surface integration work.** Cursor for engineers, Bedrock Agents for workflow automation, Vertex for GCP teams, Copilot Studio for IT ops — all speak MCP. Point them at the same URL and `get_account_summary` works for free. **One capability, N front doors.**
2. **Public reach via Cloudflare, one command.** `cloudflared tunnel --url http://localhost:3000` turns the local server into a public HTTPS endpoint. Add a bearer token for auth. Add that URL to the Slack admin page where `sobject-all` already lives. Jennifer's governed answer, in Slack, next week.
3. **More agents, same server.** Expose the Service Cloud agent, HR agent, procurement agent — each becomes a new tool name on the same MCP server. One deploy, N capabilities. Jennifer's command portfolio grows week over week with zero new infrastructure.
4. **Governance follows automatically.** Add a Trust Layer policy or an FLS restriction in Salesforce; the next call from any client — Slack, Claude Code, Bedrock — picks it up. **One place to change behavior, every surface updated.**

> [!IMPORTANT]
> **The strategic ask.** Treat this MCP server as a product, not a prototype. Fund one shared instance per environment (dev / stage / prod). Add it to the same Slack admin page where `sobject-all` lives today. Publish an internal catalog of exposed Agentforce agents. Make this the default path by which **every AI tool the business already uses** reaches Salesforce. Every new agent your Agentforce team ships becomes a new capability for Jennifer in Slack, for your developers in Claude Code, for your automations in Bedrock — on day one, with zero per-tool integration work.

---

### Appendix — The Persona in One Line

> **Jennifer Hynes, Senior AE.** Nine minutes before a renewal call. One Slack message. Three seconds later: the governed Account brief she needs — including the call-notes passage her CSM typed last Tuesday — with Trust Layer policies applied on the way out. **The agent didn't move. The data didn't move. Jennifer didn't move. Only the capability moved — to where she already was.**
