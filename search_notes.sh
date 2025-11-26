#!/bin/bash
# Search Apple Notes by name or content
# Usage: ./search_notes.sh "search term" [--name|--body|--both]

SEARCH_TERM="$1"
SEARCH_MODE="${2:---name}"  # Default to searching by name

if [ -z "$SEARCH_TERM" ]; then
    echo "Usage: $0 \"search term\" [--name|--body|--both]"
    exit 1
fi

osascript - "$SEARCH_TERM" "$SEARCH_MODE" <<'APPLESCRIPT'
on run argv
    set searchTerm to item 1 of argv
    set searchMode to item 2 of argv

    tell application "Notes"
        tell account "iCloud"
            if searchMode is "--name" then
                set foundNotes to notes whose name contains searchTerm
            else if searchMode is "--body" then
                set foundNotes to notes whose body contains searchTerm
            else if searchMode is "--both" then
                set nameMatches to notes whose name contains searchTerm
                set bodyMatches to notes whose body contains searchTerm
                set foundNotes to nameMatches & bodyMatches
            else
                return "Invalid search mode. Use --name, --body, or --both"
            end if

            set noteCount to count of foundNotes

            if noteCount = 0 then
                return "No notes found matching: " & searchTerm
            end if

            set output to "Found " & noteCount & " note(s) matching '" & searchTerm & "':" & return & return

            repeat with i from 1 to noteCount
                set aNote to item i of foundNotes
                set noteName to name of aNote
                set noteId to id of aNote
                try
                    set noteFolder to name of container of aNote
                    set output to output & i & ". " & noteName & " (" & noteFolder & ")" & return
                    set output to output & "   ID: " & noteId & return
                on error
                    set output to output & i & ". " & noteName & return
                    set output to output & "   ID: " & noteId & return
                end try
            end repeat

            return output
        end tell
    end tell
end run
APPLESCRIPT
