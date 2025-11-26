# Apple Notes MCP Server Setup

This MCP server exposes your fast Apple Notes CLI tools to both Claude Code and Claude Desktop.

## Installation for Claude Code (CLI)

**Already installed!** The MCP server has been added to your Claude Code configuration.

Verify it's working:
```bash
claude mcp list
```

You should see:
```
apple-notes: node /path/to/mcp-server.js - ✓ Connected
```

## Installation for Claude Desktop (Optional)

### 1. Configure Claude Desktop

Edit your Claude Desktop configuration file:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`

Add this configuration:

```json
{
  "mcpServers": {
    "apple-notes": {
      "command": "node",
      "args": [
        "/absolute/path/to/mcp-server.js"
      ]
    }
  }
}
```

Replace `/absolute/path/to/mcp-server.js` with the actual path to where you cloned this repository.

### 2. Restart Claude Desktop

After saving the configuration, completely quit and restart Claude Desktop.

## Available MCP Tools

Once configured, Claude will have access to these tools:

### 1. `create_note`
Create a new note with HTML formatting.

**Parameters:**
- `title` (required): Note title
- `folder` (optional): Folder name (default: "Notes")
- `content` (required): HTML content

**Example:**
```json
{
  "title": "Weekly Goals",
  "folder": "Projects",
  "content": "<h2>Goals</h2><ul><li>Task 1</li><li>Task 2</li></ul>"
}
```

### 2. `read_note`
Read a note's contents.

**Parameters:**
- `search` (required): Search term to find the note
- `format` (optional): "text" or "html" (default: "text")

**Example:**
```json
{
  "search": "Weekly Goals",
  "format": "text"
}
```

### 3. `list_notes`
List recent notes or notes in a folder.

**Parameters:**
- `folder` (optional): Folder name to filter by
- `limit` (optional): Max number of notes (default: 10)

**Example:**
```json
{
  "folder": "Projects",
  "limit": 20
}
```

### 4. `search_notes`
Search for notes by name or content.

**Parameters:**
- `query` (required): Search term
- `mode` (optional): "name", "body", or "both" (default: "name")

**Example:**
```json
{
  "query": "brainstorm",
  "mode": "both"
}
```

### 5. `delete_note`
Delete a note by searching for its title or using its exact ID.

**Parameters:**
- `search` (required): Search term to find the note by name, or exact note ID

**Examples:**
```json
{
  "search": "Old Meeting Notes"
}
```

Or for exact deletion by ID:
```json
{
  "search": "x-coredata://D8A3FA68-9A3A-4CB9-BC5A-D675F7098844/ICNote/p1234"
}
```

**Note:** This moves the note to "Recently Deleted" folder (recoverable for 30 days). If multiple notes match by title, get their IDs first using `get_note_url` for exact deletion.

### 6. `get_note_url`
Get the unique ID/URL for notes by searching for their title.

**Parameters:**
- `search` (required): Search term to find notes by name

**Example:**
```json
{
  "search": "Meeting Notes"
}
```

Returns the note ID(s) which can be used for exact deletion.

## Usage in Claude Desktop

Once set up, you can ask Claude to:
- "Create a note about today's meeting in my Projects folder"
- "Read my Weekly Goals note"
- "Search for notes about vacation planning"
- "List my recent notes in the Work folder"

Claude will use these MCP tools automatically to interact with your Apple Notes!

## Troubleshooting

### Tools not showing up
1. Check that the config file path is correct
2. Ensure the mcp-server.js path is absolute
3. Restart Claude Desktop completely
4. Check Claude Desktop logs at `~/Library/Logs/Claude/`

### Permission errors
Make sure all scripts are executable:
```bash
cd /path/to/apple-notes-mcp
chmod +x *.sh mcp-server.js
```

### Script errors
Test scripts manually first:
```bash
./create_note.sh "Test" "Notes" <<< "<h1>Test</h1>"
./list_notes.sh
./search_notes.sh "test"
./read_note.sh "test"
```

## Speed

These MCP tools are blazing fast:
- Create note: ~1 second
- Read note: ~0.6 seconds
- List notes: ~4 seconds
- Search notes: ~3 seconds

Much faster than the old `macnotesapp` CLI tool!
