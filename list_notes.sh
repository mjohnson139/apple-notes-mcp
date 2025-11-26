#!/bin/bash
# List Apple Notes
# Usage: ./list_notes.sh [folder_name] [limit]

FOLDER="$1"
LIMIT="${2:-10}"  # Default to 10 most recent notes

if [ -z "$FOLDER" ]; then
    # List recent notes from all folders
    osascript - "$LIMIT" <<'APPLESCRIPT'
on run argv
    set noteLimit to item 1 of argv as integer

    tell application "Notes"
        tell account "iCloud"
            set allNotes to notes
            set noteCount to count of allNotes

            if noteCount = 0 then
                return "No notes found."
            end if

            set displayCount to noteLimit
            if noteCount < displayCount then
                set displayCount to noteCount
            end if

            set output to "Showing " & displayCount & " of " & noteCount & " notes:" & return & return

            repeat with i from 1 to displayCount
                set aNote to item i of allNotes
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
else
    # List notes from specific folder
    osascript - "$FOLDER" "$LIMIT" <<'APPLESCRIPT'
on run argv
    set folderName to item 1 of argv
    set noteLimit to item 2 of argv as integer

    tell application "Notes"
        tell account "iCloud"
            try
                set targetFolder to folder folderName
                set folderNotes to notes of targetFolder
                set noteCount to count of folderNotes

                if noteCount = 0 then
                    return "No notes found in folder: " & folderName
                end if

                set displayCount to noteLimit
                if noteCount < displayCount then
                    set displayCount to noteCount
                end if

                set output to "Folder: " & folderName & return
                set output to output & "Showing " & displayCount & " of " & noteCount & " notes:" & return & return

                repeat with i from 1 to displayCount
                    set aNote to item i of folderNotes
                    set noteName to name of aNote
                    set noteId to id of aNote
                    set output to output & i & ". " & noteName & return
                    set output to output & "   ID: " & noteId & return
                end repeat

                return output
            on error errMsg
                return "Error: Folder '" & folderName & "' not found." & return & "Error message: " & errMsg
            end try
        end tell
    end tell
end run
APPLESCRIPT
fi
