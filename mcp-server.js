#!/usr/bin/env node

/**
 * MCP Server for Apple Notes CLI Tools
 * Exposes fast AppleScript-based notes commands as MCP tools
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require('@modelcontextprotocol/sdk/types.js');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const SCRIPT_DIR = __dirname;

// Helper function to execute shell scripts
async function executeScript(command) {
  return new Promise((resolve, reject) => {
    const proc = spawn(command, [], {
      cwd: SCRIPT_DIR,
      shell: true
    });

    let stdout = '';
    let stderr = '';

    proc.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    proc.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    proc.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr || `Script exited with code ${code}`));
      } else {
        resolve(stdout);
      }
    });

    proc.on('error', (err) => {
      reject(err);
    });
  });
}

// Create MCP server
const server = new Server(
  {
    name: 'apple-notes',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'create_note',
        description: 'Create a new note in Apple Notes with HTML formatting. Opens the note automatically in Notes.app.',
        inputSchema: {
          type: 'object',
          properties: {
            title: {
              type: 'string',
              description: 'The title of the note'
            },
            folder: {
              type: 'string',
              description: 'The folder to create the note in (default: Notes)',
              default: 'Notes'
            },
            content: {
              type: 'string',
              description: 'HTML content for the note body. Supports <h1>, <h2>, <p>, <b>, <i>, <ul>, <ol>, <li>, <hr>, etc.'
            }
          },
          required: ['title', 'content']
        }
      },
      {
        name: 'read_note',
        description: 'Read a note\'s contents by searching for its title',
        inputSchema: {
          type: 'object',
          properties: {
            search: {
              type: 'string',
              description: 'Search term to find the note by name'
            },
            format: {
              type: 'string',
              description: 'Output format: text or html',
              enum: ['text', 'html'],
              default: 'text'
            }
          },
          required: ['search']
        }
      },
      {
        name: 'list_notes',
        description: 'List recent notes or notes in a specific folder',
        inputSchema: {
          type: 'object',
          properties: {
            folder: {
              type: 'string',
              description: 'Optional folder name to filter by'
            },
            limit: {
              type: 'number',
              description: 'Maximum number of notes to return (default: 10)',
              default: 10
            }
          }
        }
      },
      {
        name: 'search_notes',
        description: 'Search for notes by name or content',
        inputSchema: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'Search term'
            },
            mode: {
              type: 'string',
              description: 'Search mode: name, body, or both',
              enum: ['name', 'body', 'both'],
              default: 'name'
            }
          },
          required: ['query']
        }
      },
      {
        name: 'delete_note',
        description: 'Delete a note (moves to Recently Deleted folder) by searching for its title or using its exact ID. Recoverable for 30 days.',
        inputSchema: {
          type: 'object',
          properties: {
            search: {
              type: 'string',
              description: 'Search term to find the note by name, or exact note ID (x-coredata://...)'
            }
          },
          required: ['search']
        }
      },
      {
        name: 'get_note_url',
        description: 'Get the unique ID/URL for notes by searching for their title. Use this to get exact note IDs for deletion.',
        inputSchema: {
          type: 'object',
          properties: {
            search: {
              type: 'string',
              description: 'Search term to find notes by name'
            }
          },
          required: ['search']
        }
      },
      {
        name: 'list_folders',
        description: 'List all folders with metadata (note count, etc.)',
        inputSchema: {
          type: 'object',
          properties: {}
        }
      },
      {
        name: 'search_folders',
        description: 'Search for folders by name',
        inputSchema: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'Search term to find folders by name'
            }
          },
          required: ['query']
        }
      }
    ]
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    let result;

    switch (name) {
      case 'create_note': {
        const { title, folder = 'Notes', content } = args;
        const scriptPath = path.join(SCRIPT_DIR, 'create_note.sh');

        // Write content to temp file
        const tempFile = `/tmp/note-content-${Date.now()}.html`;
        fs.writeFileSync(tempFile, content);

        try {
          const output = await executeScript(`cat "${tempFile}" | "${scriptPath}" "${title}" "${folder}"`);
          fs.unlinkSync(tempFile);
          result = `Note "${title}" created successfully in folder "${folder}"`;
        } catch (err) {
          fs.unlinkSync(tempFile);
          throw err;
        }
        break;
      }

      case 'read_note': {
        const { search, format = 'text' } = args;
        const scriptPath = path.join(SCRIPT_DIR, 'read_note.sh');
        const formatFlag = format === 'html' ? '--html' : '--text';
        result = await executeScript(`"${scriptPath}" "${search}" ${formatFlag}`);
        break;
      }

      case 'list_notes': {
        const { folder = '', limit = 10 } = args;
        const scriptPath = path.join(SCRIPT_DIR, 'list_notes.sh');
        const folderArg = folder ? `"${folder}"` : '""';
        result = await executeScript(`"${scriptPath}" ${folderArg} ${limit}`);
        break;
      }

      case 'search_notes': {
        const { query, mode = 'name' } = args;
        const scriptPath = path.join(SCRIPT_DIR, 'search_notes.sh');
        const modeFlag = `--${mode}`;
        result = await executeScript(`"${scriptPath}" "${query}" ${modeFlag}`);
        break;
      }

      case 'delete_note': {
        const { search } = args;
        const scriptPath = path.join(SCRIPT_DIR, 'delete_note.sh');
        result = await executeScript(`"${scriptPath}" "${search}"`);
        break;
      }

      case 'get_note_url': {
        const { search } = args;
        const scriptPath = path.join(SCRIPT_DIR, 'get_note_url.sh');
        result = await executeScript(`"${scriptPath}" "${search}"`);
        break;
      }

      case 'list_folders': {
        const scriptPath = path.join(SCRIPT_DIR, 'list_folders.sh');
        result = await executeScript(`"${scriptPath}"`);
        break;
      }

      case 'search_folders': {
        const { query } = args;
        const scriptPath = path.join(SCRIPT_DIR, 'search_folders.sh');
        result = await executeScript(`"${scriptPath}" "${query}"`);
        break;
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }

    return {
      content: [
        {
          type: 'text',
          text: result
        }
      ]
    };
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error.message}`
        }
      ],
      isError: true
    };
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);

  // Log to stderr so it doesn't interfere with stdio protocol
  console.error('Apple Notes MCP server running on stdio');
}

main().catch((error) => {
  console.error('Fatal error in main():', error);
  process.exit(1);
});
