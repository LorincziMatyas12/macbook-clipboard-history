on run argv
    try
        set entryList to {}
        
        -- Split the input string on commas
        set AppleScript's text item delimiters to {","}
        set entryList to text items of (item 1 of argv)
        
        set selectedItem to choose from list entryList with prompt "Select clipboard entry:" default items {}
        
        -- Return the selected item or empty string if cancelled
        if selectedItem is false then
            return ""
        else
            -- Log the selected item to a file for debugging
            do shell script "echo 'Selected: " & (item 1 of selectedItem) & "' >> /tmp/clipboard_debug.log"
            return item 1 of selectedItem
        end if
    on error errMsg
        -- Log any errors
        do shell script "echo 'AppleScript Error: " & errMsg & "' >> /tmp/clipboard_debug.log"
        return ""
    end try
end runcd