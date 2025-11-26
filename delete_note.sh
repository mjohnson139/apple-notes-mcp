#!/bin/bash
# Delete an Apple Note (moves to Recently Deleted folder) by searching for its name or using its ID
# Note: Deleted notes can be recovered from Recently Deleted folder within 30 days
# Usage: ./delete_note.sh "Note Title"
# Usage: ./delete_note.sh "x-coredata://..."

SEARCH_TERM="$1"

if [ -z "$SEARCH_TERM" ]; then
    echo "Usage: $0 \"Note Title or Note ID\""
    exit 1
fi

osascript - "$SEARCH_TERM" <<'APPLESCRIPT'
on run argv
    set searchTerm to item 1 of argv

    tell application "Notes"
        tell account "iCloud"
            -- Check if searchTerm is a note ID (starts with x-coredata://)
            if searchTerm starts with "x-coredata://" then
                try
                    set theNote to note id searchTerm
                    set noteName to name of theNote

                    try
                        set noteFolder to name of container of theNote
                    on error
                        set noteFolder to "(unknown)"
                    end try

                    -- Delete the note (moves to Recently Deleted)
                    delete theNote

                    return "Moved to trash: " & noteName & " (was in folder: " & noteFolder & ")"
                on error errMsg
                    return "Error: Could not find or delete note with ID: " & searchTerm & return & "Error message: " & errMsg
                end try
            else
                -- Search by name
                set foundNotes to notes whose name contains searchTerm

                if (count of foundNotes) = 0 then
                    return "No notes found matching: " & searchTerm
                end if

                if (count of foundNotes) > 1 then
                    set noteList to "Multiple notes found:" & return
                    repeat with i from 1 to (count of foundNotes)
                        set aNote to item i of foundNotes
                        set noteId to id of aNote
                        try
                            set folderName to name of container of aNote
                            set noteList to noteList & "  " & i & ". " & (name of aNote) & " (in folder: " & folderName & ")" & return
                            set noteList to noteList & "     ID: " & noteId & return
                        on error
                            set noteList to noteList & "  " & i & ". " & (name of aNote) & return
                            set noteList to noteList & "     ID: " & noteId & return
                        end try
                    end repeat
                    return noteList & return & "Please use the specific note ID to delete the exact note you want."
                end if

                set theNote to item 1 of foundNotes
                set noteName to name of theNote

                try
                    set noteFolder to name of container of theNote
                on error
                    set noteFolder to "(unknown)"
                end try

                -- Delete the note (moves to Recently Deleted)
                delete theNote

                return "Moved to trash: " & noteName & " (was in folder: " & noteFolder & ")"
            end if
        end tell
    end tell
end run
APPLESCRIPT
