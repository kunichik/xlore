# xlore-mcp

A **read-only** [MCP](https://modelcontextprotocol.io) server over your local xlore archive. It lets
MCP-capable chat assistants (Claude Desktop, etc.) **read** your knowledge — search it, locate which
tool/chat you did something in, read a page, see recent activity — without giving them write access.

> Writes are deliberately not exposed. The triage-first write guarantee lives in the filesystem-agent
> flow (`CLAUDE.md`); a read-only server can never bypass it. Hosted write tools are a later phase.

## Tools

| Tool | Does |
|---|---|
| `xlore_query` | Keyword search across `wiki/` + `raw/`, ranked, with source paths |
| `xlore_where` | "In which tool/chat did I do X?" — scans `log.md` + `active.md` |
| `xlore_read` | Read one page by relative path (path-traversal guarded) |
| `xlore_recent` | Recent log entries + the live active board |

## Build

```bash
cd mcp
npm install
npm run build      # → dist/index.js   (or: npm run dev  to run from source via tsx)
```

## Wire it into Claude Desktop

Add to `claude_desktop_config.json` (macOS: `~/Library/Application Support/Claude/`):

```json
{
  "mcpServers": {
    "xlore": {
      "command": "node",
      "args": ["/absolute/path/to/your-xlore/mcp/dist/index.js"],
      "env": { "XLORE_ROOT": "/absolute/path/to/your-xlore" }
    }
  }
}
```

`XLORE_ROOT` defaults to the repo this server ships in (`../..`), so it's only needed if you run the
binary from elsewhere. Restart Claude Desktop; the four `xlore_*` tools appear.

Cursor and other MCP clients use the same command/args/env in their own MCP config.

## Scope & roadmap

- **Now:** local stdio, read-only, keyword search (no external calls — your archive never leaves the machine).
- **Later:** semantic search (embeddings); a **hosted** transport for Claude web/mobile + ChatGPT
  connectors (adds auth + a data-on-server privacy surface — see `../PRIVACY.md`).
