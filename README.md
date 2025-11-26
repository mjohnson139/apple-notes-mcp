# Fast Apple Notes CLI Tools

Lightning-fast AppleScript-based tools for managing Apple Notes from the command line.

## Performance

These scripts are **18-120x faster** than the `macnotesapp` CLI tool:
- Create note: ~1s (vs 16s)
- List notes: ~4s (vs 24s)
- Search notes: ~3s (vs unknown)

## Commands

### 1. Create a Note
```bash
./create_note.sh "Note Title" "FolderName" < content.html
```

**Examples:**
```bash
# Create in default "Notes" folder
./create_note.sh "My New Note" "Notes" << 'EOF'
<h1>Hello World</h1>
<p>This is <b>bold</b> and <i>italic</i> text.</p>
<ul>
  <li>Bullet point 1</li>
  <li>Bullet point 2</li>
</ul>
EOF

# Create in "Projects" folder
./create_note.sh "Project Plan" "Projects" << 'EOF'
<h2>Q4 Goals</h2>
<ul><li>Goal 1</li><li>Goal 2</li></ul>
EOF
```

### 2. List Notes
```bash
# List 10 most recent notes (default)
./list_notes.sh

# List 20 most recent notes
./list_notes.sh "" 20

# List notes in specific folder
./list_notes.sh "Projects"

# List first 5 notes in folder
./list_notes.sh "Projects" 5
```

### 3. Search Notes
```bash
# Search by name (default)
./search_notes.sh "search term"

# Search in note body/content
./search_notes.sh "search term" --body

# Search both name and body
./search_notes.sh "search term" --both
```

### 4. Read a Note
```bash
# Read note (text format with headers)
./read_note.sh "Note Title"

# Read note (raw HTML)
./read_note.sh "Note Title" --html
```

**Note:** If multiple notes match, it shows the first one with a warning.

### 5. Get Note URL/ID
```bash
# Get the unique ID for notes
./get_note_url.sh "Note Title"
```

This returns the note ID(s) in format: `x-coredata://...`

### 6. Delete a Note
```bash
# Delete a note by searching for its title
./delete_note.sh "Note Title"

# Delete a specific note by ID (for exact deletion)
./delete_note.sh "x-coredata://D8A3FA68-9A3A-4CB9-BC5A-D675F7098844/ICNote/p1234"
```

**Note:** This moves the note to "Recently Deleted" folder where it can be recovered within 30 days. If multiple notes match by title, it will show their IDs - use the specific ID to delete the exact note you want.

## HTML Formatting Guide

Apple Notes supports these HTML tags:

### Headings
```html
<h1>Main Title</h1>
<h2>Section Title</h2>
<h3>Subsection</h3>
```

### Text Formatting
```html
<b>Bold text</b>
<i>Italic text</i>
<u>Underlined text</u>
```

### Lists
```html
<!-- Bullet list -->
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>

<!-- Numbered list -->
<ol>
  <li>First</li>
  <li>Second</li>
</ol>

<!-- Nested lists -->
<ul>
  <li>Item 1
    <ul>
      <li>Sub-item 1</li>
      <li>Sub-item 2</li>
    </ul>
  </li>
</ul>
```

### Other Elements
```html
<hr>           <!-- Horizontal line -->
<p>Paragraph</p>
&amp;          <!-- Ampersand (&) -->
&lt;           <!-- Less than (<) -->
&gt;           <!-- Greater than (>) -->
```

### Emojis
Just use emojis directly: 🎯 💪 📚 🏠 👥 💰 🎨 📝

## Interactive Checklists

**Important:** Interactive checkboxes cannot be created programmatically.

**Workaround:**
1. Create note with regular bullets
2. Open in Notes.app
3. Select lines and press **Shift+Cmd+L** to convert to checklists

## Available Folders

Common folder examples:
- Notes (default)
- Projects
- Work
- Personal
- Ideas

You can create and organize your own folders in Apple Notes. Run `./list_notes.sh` to see your available folders.

## Tips

1. **Speed:** These scripts are much faster than the old `notes` CLI tool
2. **Brainstorming:** Use these to quickly capture formatted notes from terminal
3. **Integration:** Easy to integrate with other scripts and automation
4. **Preview:** Notes auto-open in Notes.app with `--show` behavior built-in
