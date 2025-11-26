#!/bin/bash
# Quick Apple Notes creator using AppleScript
# Usage: ./create_note.sh "Note Title" "folder" < content.html

NOTE_TITLE="$1"
FOLDER="${2:-Notes}"  # Default to "Notes" folder

# Read content from stdin and save to temp file
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE"

# Use AppleScript with heredoc to avoid escaping issues
osascript - "$NOTE_TITLE" "$FOLDER" "$TEMP_FILE" <<'APPLESCRIPT'
on run argv
    set noteTitle to item 1 of argv
    set folderName to item 2 of argv
    set tempFile to item 3 of argv

    set noteContent to read POSIX file tempFile as «class utf8»

    tell application "Notes"
        tell account "iCloud"
            set newNote to make new note at folder folderName with properties {name:noteTitle}
            set body of newNote to noteContent
            show newNote
        end tell
    end tell
end run
APPLESCRIPT

# Clean up
rm "$TEMP_FILE"
