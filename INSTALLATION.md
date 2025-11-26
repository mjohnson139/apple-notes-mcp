# Apple Notes MCPB Extension - Installation Guide

Your Apple Notes MCP server has been successfully packaged as a Desktop Extension!

## Package Information

- **File**: `apple-notes-1.1.0.mcpb`
- **Size**: 5.0 MB (packaged), 17.8 MB (unpacked)
- **Platform**: macOS only (darwin)
- **Total Files**: 3,413

## Installation Methods

### Method 1: Double-Click Installation (Easiest)

1. Locate the `apple-notes-1.1.0.mcpb` file
2. Double-click it
3. Claude Desktop will automatically open and show an installation dialog
4. Click "Install" to add the extension
5. The extension will be available immediately

### Method 2: Claude Desktop Menu Installation

1. Open Claude Desktop
2. Go to **Settings** → **Extensions**
3. Click **Install Extension**
4. Navigate to and select `apple-notes-1.1.0.mcpb`
5. Click **Open** to install

### Method 3: Claude Code CLI Installation

**Note:** Claude Code CLI does not use `.mcpb` files. Install the MCP server directly:

```bash
# Clone or download this repository first, then:
cd /path/to/apple-notes-mcp

# Add the MCP server to Claude Code
claude mcp add --transport stdio apple-notes node $(pwd)/mcp-server.js

# Verify installation
claude mcp list
# You should see: apple-notes: node /path/to/mcp-server.js - ✓ Connected
```

Replace `/path/to/apple-notes-mcp` with the actual path where you cloned this repository.

## Verifying Installation

After installation, you should see the Apple Notes extension in your Claude client with access to these tools:

- `mcp__apple-notes__create_note` - Create formatted notes with HTML
- `mcp__apple-notes__read_note` - Read note contents by title
- `mcp__apple-notes__list_notes` - List notes from specific folders
- `mcp__apple-notes__search_notes` - Search notes by name or content
- `mcp__apple-notes__delete_note` - Delete notes (moves to Recently Deleted)
- `mcp__apple-notes__get_note_url` - Get unique note IDs
- `mcp__apple-notes__list_folders` - List all folders with metadata
- `mcp__apple-notes__search_folders` - Search folders by name

## Testing the Extension

Once installed, try these commands in Claude:

```
List my recent notes
```

```
Create a note titled "Test Note" with content "Hello from Claude!"
```

```
Search for notes containing "test"
```

## Troubleshooting

### Extension Won't Install
- Ensure you're running Claude Desktop on macOS (this extension is macOS-only)
- Check that you have the latest version of Claude Desktop
- Verify the `.mcpb` file is not corrupted

### Tools Not Appearing
- Restart Claude Desktop after installation
- Check Extensions settings to ensure the extension is enabled

### Permission Issues
- The extension needs access to Apple Notes
- macOS may prompt you to grant permissions the first time you use it
- You may need to grant permissions in System Settings → Privacy & Security → Automation

## Uninstallation

To remove the extension:

1. Open Claude Desktop
2. Go to **Settings** → **Extensions**
3. Find "Apple Notes" in the list
4. Click **Uninstall** or **Remove**

## Distribution

To share this extension with others:

1. Send them the `apple-notes-1.1.0.mcpb` file
2. They can install it using any of the methods above
3. Note: Recipients must be running macOS (the extension won't work on Windows/Linux)

## Updating the Extension

To create a new version:

1. Make changes to your source files
2. Update the version in `manifest.json`
3. Run `mcpb pack` to create a new `.mcpb` file
4. Install the new version (it will replace the old one)

## Technical Details

- **Runtime**: Node.js (bundled with Claude)
- **Protocol**: MCP (Model Context Protocol) via stdio
- **Dependencies**: All bundled in the package (no external installation needed)
- **Scripts**: Uses AppleScript for fast native Apple Notes integration

## Support

For issues or questions:
- Check the README.md for usage examples
- Review MCP_SETUP.md for MCP server details
- Submit issues to your repository if you're hosting this publicly
