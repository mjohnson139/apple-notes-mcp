#!/bin/bash
# Search Apple Notes Folders by name
# Usage: ./search_folders.sh "search term"

SEARCH_QUERY="$1"

if [ -z "$SEARCH_QUERY" ]; then
    echo "Usage: $0 \"search term\""
    exit 1
fi

osascript - "$SEARCH_QUERY" <<'APPLESCRIPT'
on run argv
    set searchQuery to item 1 of argv

    tell application "Notes"
        tell account "iCloud"
            set allFolders to folders
            set matchingFolders to {}

            repeat with aFolder in allFolders
                if name of aFolder contains searchQuery then
                    set end of matchingFolders to aFolder
                end if
            end repeat

            set matchCount to count of matchingFolders

            if matchCount = 0 then
                return "No folders found matching: " & searchQuery
            end if

            set output to "Found " & matchCount & " folder(s) matching '" & searchQuery & "':" & return & return

            repeat with i from 1 to matchCount
                set aFolder to item i of matchingFolders
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
end run
APPLESCRIPT
