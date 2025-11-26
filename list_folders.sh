#!/bin/bash
# List Apple Notes Folders
# Usage: ./list_folders.sh

osascript <<'APPLESCRIPT'
tell application "Notes"
    tell account "iCloud"
        set allFolders to folders
        set folderCount to count of allFolders

        if folderCount = 0 then
            return "No folders found."
        end if

        set output to "Found " & folderCount & " folder(s):" & return & return

        repeat with i from 1 to folderCount
            set aFolder to item i of allFolders
            set folderName to name of aFolder

            try
                set noteCount to count of notes of aFolder
                set output to output & i & ". " & folderName & " (" & noteCount & " notes)" & return
            on error
                set output to output & i & ". " & folderName & " (note count unavailable)" & return
            end try
        end repeat

        return output
    end tell
end tell
APPLESCRIPT
