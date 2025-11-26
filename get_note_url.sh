#!/bin/bash
# Get the URL/ID for a note by searching for its name
# Usage: ./get_note_url.sh "Note Title"

SEARCH_TERM="$1"

if [ -z "$SEARCH_TERM" ]; then
    echo "Usage: $0 \"Note Title\""
    exit 1
fi

osascript - "$SEARCH_TERM" <<'APPLESCRIPT'
on run argv
    set searchTerm to item 1 of argv

    tell application "Notes"
        tell account "iCloud"
            set foundNotes to notes whose name contains searchTerm

            if (count of foundNotes) = 0 then
                return "No notes found matching: " & searchTerm
            end if

            set output to "Found " & (count of foundNotes) & " note(s):" & return & return

            repeat with i from 1 to (count of foundNotes)
                set aNote to item i of foundNotes
                set noteName to name of aNote
                set noteId to id of aNote

                try
                    set noteFolder to name of container of aNote
                on error
                    set noteFolder to "(unknown)"
                end try

                set output to output & i & ". " & noteName & return
                set output to output & "   Folder: " & noteFolder & return
                set output to output & "   ID: " & noteId & return & return
            end repeat

            return output
        end tell
    end tell
end run
APPLESCRIPT
