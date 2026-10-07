# Agentforce Account Summary MCP

Streamable-HTTP MCP server that wraps the Salesforce Agent API and exposes the
Account Summary Agentforce agent as a single tool: `get_account_summary`.

Any MCP-aware client (Claude Code, Claude Desktop, Amazon Bedrock, Google Vertex,
Cursor, etc.) can call this server over HTTPS to retrieve a markdown summary of
a Salesforce Account by Name or Id.

## Architecture

```
┌─────────────────┐    HTTPS /mcp     ┌──────────────────┐    OAuth cc    ┌─────────────────────┐
│  MCP Client     │ ─────────────────► │  This server     │ ─────────────► │ Salesforce          │
│  (Claude Code)  │  Streamable HTTP   │  (Node + Express)│    Agent API   │ Account Summary     │
└─────────────────┘                    └──────────────────┘                │ Agentforce agent    │
       ▲                                      ▲                            └─────────────────────┘
       │  Cloudflare tunnel                   │
       └──────────────────────────────────────┘
          (public HTTPS URL → localhost:3000)
```

## Prerequisites

1. **Account Summary Agentforce agent** published and activated in your org
   (NOT type `Agentforce (Default)` — Agent API doesn't support it).
2. **External Client App** with scopes: `api`, `chatbot_api`, `sfap_api`,
   `refresh_token`, Client Credentials Flow enabled, JWT access tokens enabled,
   Run As = an API-only user that can run the agent.
3. **`cloudflared`** installed if you want to expose the server publicly:
   `brew install cloudflared` on macOS.

## Setup

```bash
cd mcp-server
npm install
cp env.example .env
# fill in SF_MY_DOMAIN_URL, SF_CONSUMER_KEY, SF_CONSUMER_SECRET, SF_AGENT_ID
# generate and set MCP_BEARER_TOKEN before tunneling:
node -e "console.log(require('crypto').randomBytes(24).toString('hex'))"
npm run build
npm start
# → [agentforce-mcp] ready on :3000 (POST /mcp) [bearer auth enabled]
```

Quick local check:

```bash
curl -s http://localhost:3000/health
# → {"ok":true,"agentId":"0Xx..."}
```

## Expose with Cloudflare Tunnel

### Option A — Free quick tunnel (ephemeral `trycloudflare.com` URL)

No account, no DNS. Prints a one-shot URL you can use immediately:

```bash
cloudflared tunnel --url http://localhost:3000
# → Your quick tunnel is https://random-slug.trycloudflare.com
```

The URL changes every time you restart. Fine for a demo/workshop.

### Option B — Named tunnel on your own domain ($10 for a `.com`)

```bash
cloudflared login                         # auth to Cloudflare
cloudflared tunnel create agentforce-mcp
cloudflared tunnel route dns agentforce-mcp mcp.yourdomain.com
cloudflared tunnel run agentforce-mcp --url http://localhost:3000
```

Durable URL, survives restarts, nicer for registering in Salesforce.

## Register with MCP clients

### Claude Code (`~/.claude/settings.json` or `./.claude/settings.json`)

```json
{
  "mcpServers": {
    "agentforce-account-summary": {
      "type": "http",
      "url": "https://random-slug.trycloudflare.com/mcp",
      "headers": {
        "Authorization": "Bearer <paste MCP_BEARER_TOKEN here>"
      }
    }
  }
}
```

Then in Claude Code: `/mcp` to confirm it's connected, then ask something like
"Use `get_account_summary` to summarize the Edge Communications account."

### Claude Desktop

Same shape, placed in `claude_desktop_config.json`.

### Bedrock / Vertex / Cursor

Any MCP-compliant client that supports Streamable HTTP will work. Point it at
`https://<tunnel>/mcp` with the bearer header.

## (Optional) Register in Salesforce Agentforce Registry

If you want Agentforce agents inside Salesforce to call *this* MCP server as a
tool, create a Named Credential + register in Agentforce Registry.

### 1. Named Credential (Setup)

Setup → **Named Credentials** → **New Named Credential**:

- **Label / Name:** `Agentforce_Account_Summary_MCP`
- **URL:** `https://<your-tunnel>` (no trailing slash, no `/mcp` path — the path lives in the external service registration)
- **Authentication Protocol:** Password Authentication (or Custom Headers, if your bearer token is static)
- **Allowed Namespaces:** blank
- **Generate Authorization Header:** on
- Save

If using **Custom Headers** instead, add:
- Header name: `Authorization`
- Header value: `Bearer <MCP_BEARER_TOKEN>`

### 2. Register in Agentforce Registry

Setup → **Agentforce Registry** → **New**:

- Server URL: `https://<your-tunnel>/mcp`
- Auth: No Auth (if your tunnel is unauthenticated) or OAuth 2.0 client credentials
- The registry validates the server, lists tools, and you allowlist `get_account_summary`

See the official docs for the full flow: [Register a Third-Party MCP Server in Agentforce Registry](https://help.salesforce.com/s/articleView?id=ai.agent_mcp_connect_register.htm).

## Troubleshooting

| Error | Fix |
|---|---|
| `400` on token | Wrong My Domain URL (use `*.my.salesforce.com`, not `*.lightning.force.com`). |
| `401` on session start | ECA scopes missing `sfap_api` and `chatbot_api`. |
| `404 Agent not found` | Agent must be *activated*, not just deployed. Re-check `sf agent activate`. |
| `401 Unauthorized` from MCP | Client isn't sending `Authorization: Bearer <MCP_BEARER_TOKEN>`. |
| Empty summary | Einstein Agent User lacks object permissions, OR the Apex uses `WITH USER_MODE` and silently returns zero rows. Switch to `WITH SYSTEM_MODE` for demo orgs. |

## Env reference

| Variable                | Required | Default                       |
| ----------------------- | -------- | ----------------------------- |
| `SF_MY_DOMAIN_URL`      | yes      | —                             |
| `SF_CONSUMER_KEY`       | yes      | —                             |
| `SF_CONSUMER_SECRET`    | yes      | —                             |
| `SF_AGENT_ID`           | yes      | —                             |
| `SF_EINSTEIN_API_BASE`  | no       | `https://api.salesforce.com`  |
| `PORT`                  | no       | `3000`                        |
| `MCP_BEARER_TOKEN`      | no       | — (open if unset — set it before tunneling!) |
