# Agentforce Everywhere — Value Proposition

### A persona-led case for exposing Salesforce agents in Slack and other AI surfaces

---

## 1 · The Problem We're Solving — Jennifer's 10-Minute Window

**Meet Jennifer Hynes.** Senior Account Executive, mid-market SaaS, five years in the seat. Jennifer's calendar is a wall of back-to-back customer calls. Between a sync with Legal and a renewal pitch with **Omega, Inc.**, she has nine minutes. The last conversation with Omega was six weeks ago. There's a half-remembered mention of a budget freeze, a case her CSM filed, and a new contact a colleague added. All of it is in Salesforce. None of it is in her head.

Jennifer's current playbook: open Salesforce, type the account name, click into the record, scroll to Related, open Opportunities in a new tab, flip to Cases, hunt for the contact list, dig into Chatter for notes. **Three minutes gone, half the signals missed, and she's still in a browser tab instead of in Slack where her team is waiting.**

Jennifer doesn't need a new AI tool. She needs the AI that already lives in her Slack to **know how to talk to the agent her Salesforce team already built.** That is the gap this project closes. We're not building another chatbot. We're building the **wire** that lets every AI surface the business already uses — Slack, Claude Code on a developer's laptop, Cursor, Bedrock, Vertex — reach into Salesforce and ask the governed Agentforce agent for the same, consistent, policy-safe answer. **One agent in Salesforce. Every channel the business already lives in.**

> *"@Claude, give me a snapshot on Omega, Inc. before my 11 am."*
>
> Three seconds later, in the same Slack thread: a tight markdown brief — company info, latest call notes, top open opp, open case status, key contacts, closed-won total. Jennifer reads it, walks into the Zoom, opens the call with the renewal number her CSM filed last Tuesday. Omega hears "you're paying attention." The call lands.

---

## 2 · Architecture at a Glance — The Four Pieces

Four things are in play, in order from **where the human is** to **where the data is**:

| # | Piece | Role in the story |
|---|---|---|
| 1 | **Slack** | Where Jennifer lives. The channel she's already in; the surface she doesn't need to be re-trained on. |
| 2 | **Claude** | The AI brain. In Slack as *Claude Tag*; on a dev's laptop as *Claude Code*. Speaks MCP natively; speaks no Salesforce. |
| 3 | **The MCP server** (this project) | The translator. MCP on one side, Salesforce Agent API on the other. ~250 lines of Node. |
| 4 | **Agentforce + Salesforce** | The brain of record. The agent, its actions, its data, its governance — all inside the org. |

```
                                               PRIYA (Slack)
                                                      │
                                                      │  "@Claude, snapshot on
                                                      │   Omega, Inc. before 11."
                                                      ▼
                                              ┌────────────────┐
                                              │  Claude Tag    │
                                              │  (Claude in    │
                                              │   Slack)       │
                                              └────────┬───────┘
                                                       │ MCP JSON-RPC
                                                       │ POST /mcp
                                                       ▼
   ┌──────────────┐           MCP JSON-RPC    ┌────────────────┐
   │ Claude Code  │ ─── POST /mcp ──────────► │   MCP server   │ ◄── other MCP
   │  (dev tool)  │ ◄── markdown reply ────── │   (Node app)   │     clients
   └──────────────┘                           └────────┬───────┘  (Cursor, Bedrock,
                                                       │           Vertex, Copilot
                                               HTTPS over internet  Studio, …)
                                                       │
                               ┌───────────────────────┼──────────────────────┐
                               │ SALESFORCE ORG        │                      │
                               │                       ▼                      │
                               │    ┌───────────────────────────────────────┐ │
                               │    │ 1) OAuth client-credentials           │ │
                               │    │    POST /services/oauth2/token        │ │
                               │    │    → short-lived access_token         │ │
                               │    └───────────────────────────────────────┘ │
                               │                   │                          │
                               │                   ▼ bearer token             │
                               │    ┌───────────────────────────────────────┐ │
                               │    │ 2) Agent API                          │ │
                               │    │    POST /agents/{id}/sessions         │ │
                               │    │    POST /sessions/{sid}/messages      │ │
                               │    └───────────────────┬───────────────────┘ │
                               │                        │                     │
                               │                        ▼                     │
                               │    ┌───────────────────────────────────────┐ │
                               │    │ 3) AccountSummaryAgent                │ │
                               │    │    (Agentforce, aiAuthoringBundle)    │ │
                               │    │    "Call Get Account Summary action"  │ │
                               │    └───────────────────┬───────────────────┘ │
                               │                        │                     │
                               │                        ▼                     │
                               │    ┌───────────────────────────────────────┐ │
                               │    │ 4) AccountSummaryAction (Apex)        │ │
                               │    │    SOQL: Account, Opp, Case, Contact, │ │
                               │    │          Call_Notes__c                │ │
                               │    │    → markdown brief                   │ │
                               │    └───────────────────────────────────────┘ │
                               │                                              │
                               └──────────────────────────────────────────────┘
```

Think of it as a **universal remote control** for Salesforce agents. The TV is the Agentforce agent inside the org. The remote is the MCP server. Jennifer in Slack and the dev in Claude Code press buttons on the same remote; the agent on the TV does the work. **One remote. One agent. Many front doors.**

---

## 3 · How the Systems Are Connected — Six Hops, One Answer

Follow Jennifer's `@Claude` message from Slack all the way to a Salesforce record and back:

| # | Hop | Protocol | What travels |
|---|---|---|---|
| 1 | **Jennifer → Slack** | Slack native | "@Claude, snapshot on Omega, Inc. …" |
| 2 | **Slack → Claude Tag** | Slack Events API webhook | Message payload with user, channel, thread |
| 3 | **Claude → MCP server** | MCP (JSON-RPC over HTTP) | `tools/call: get_account_summary(account="Omega, Inc.")` |
| 4 | **MCP server → Salesforce OAuth** | form-urlencoded | `grant_type=client_credentials` → access_token |
| 5 | **MCP server → Agent API** | REST JSON + Bearer | Start session, send message — Agent API spins up the agent |
| 6 | **Agent → Apex invocable → SOQL → Salesforce data** | internal | `AccountSummaryAction.execute(...)` runs, hits Account/Opp/Case/Contact/Call_Notes__c |
| ↩ | **Reply flows back** | each layer unwraps | Markdown brief lands in Jennifer's Slack thread |

**Three structural properties that matter for IT:**

1. **Governance lives in Salesforce, not in the client.** Trust Layer masking, FLS, sharing rules, prompt policies — all configured once in the org. Every channel (Slack, Claude Code, Bedrock) inherits them automatically.
2. **The MCP server is stateless.** OAuth tokens cached in memory for ~25 min; one Agent API session per request, closed after each reply. Kill the server; no data lost.
3. **No new Salesforce APIs invented.** We use already-GA Salesforce Agent API + Client-Credentials OAuth. The only new code is ~250 lines of TypeScript in the MCP server.

---

## 4 · Extensibility — Where This Goes Next

Today Jennifer calls the agent from Slack. The exact same MCP server, with no code changes, extends in four directions:

1. **New AI surfaces, zero per-surface integration work.** Cursor for engineers, Bedrock Agents for workflow automation, Vertex for GCP teams, Copilot Studio for IT ops — all speak MCP. Point them at the same URL and `get_account_summary` works for free. **One capability, N front doors.**
2. **Public reach via Cloudflare, one command.** `cloudflared tunnel --url http://localhost:3000` turns the local server into a public HTTPS endpoint. Now Slack's cloud, Bedrock in AWS, or Vertex in GCP can reach it. Add a bearer token for auth. Done.
3. **More agents, same server.** Expose the Service Cloud agent, the HR agent, the procurement agent — each becomes a new tool name on the same MCP server. One deploy, N capabilities. Jennifer's `@Claude` command portfolio grows week over week with zero new infrastructure.
4. **Governance follows automatically.** Add a Trust Layer policy or an FLS restriction in Salesforce; the next call from any client — Slack, Claude Code, Bedrock — picks it up. **One place to change behavior, every surface updated.**

> [!IMPORTANT]
> **The strategic ask.** Treat this MCP server as a product, not a prototype. Fund one shared instance per environment (dev / stage / prod), publish an internal catalog of exposed Agentforce agents, and make this the default path by which **every AI tool the business already uses** reaches Salesforce. Every new agent your Agentforce team ships becomes a new capability for Jennifer in Slack, for your developers in Claude Code, for your automation workflows in Bedrock — on day one, with zero per-tool work.

---

### Appendix — The Persona in One Line

> **Jennifer Hynes, Senior AE.** Nine minutes before a renewal call. One Slack message. Three seconds later: the Account brief she needs. **The agent didn't move. The data didn't move. Jennifer didn't move. Only the capability moved — to where she already was.**
