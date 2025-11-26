#!/bin/bash
# Read an Apple Note by searching for its name
# Usage: ./read_note.sh "Note Title" [--html|--text]

SEARCH_TERM="$1"
FORMAT="${2:---text}"  # Default to text format

if [ -z "$SEARCH_TERM" ]; then
    echo "Usage: $0 \"Note Title\" [--html|--text]"
    exit 1
fi

osascript - "$SEARCH_TERM" "$FORMAT" <<'APPLESCRIPT'
on run argv
    set searchTerm to item 1 of argv
    set outputFormat to item 2 of argv

    tell application "Notes"
        tell account "iCloud"
            set foundNotes to notes whose name contains searchTerm

            if (count of foundNotes) = 0 then
                return "No notes found matching: " & searchTerm
            end if

            set theNote to item 1 of foundNotes
            set noteName to name of theNote
            set noteBody to body of theNote

            try
                set noteFolder to name of container of theNote
            on error
                set noteFolder to "(unknown)"
            end try

            set warningMsg to ""
            if (count of foundNotes) > 1 then
                set warningMsg to "[Note: Found " & (count of foundNotes) & " matches. Showing first one.]" & return & return
            end if

            if outputFormat is "--html" then
                return noteBody
            else
                -- Return formatted text output
                return warningMsg & "Title: " & noteName & return & "Folder: " & noteFolder & return & "---" & return & noteBody
            end if
        end tell
    end tell
end run
APPLESCRIPT
