#!/bin/bash
# FILENAME: clipboard-history.sh
# AUTHOR: Lorinczi Matyas
# DESCRIPTION: A simple clipboard history tool for macOS using shell scripts and AppleScript.

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HISTORY_FILE="$HOME/macos-clipboard-history/.env/.clipboard_history.json"
PID_FILE="$HOME/macos-clipboard-history/.env/.clipboard_listener_pid"
DEBUG_LOG="/tmp/clipboard_debug.log"

# Debug function
debug_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$DEBUG_LOG"
}

# Function to show history with timestamps
show_history() {
    debug_log "Starting show_history function"
    
    # Validate JSON before showing history
    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        debug_log "History file is empty or doesn't exist"
        osascript -e 'display dialog "Clipboard history is empty." buttons {"OK"}'
        return
    fi

    # Process JSON and create formatted entries
    debug_log "Running format_entries.py"
    ENTRIES=$(python3 "$SCRIPT_DIR/format_entries.py" "$HISTORY_FILE")
    debug_log "Entries received: $ENTRIES"

    if [[ -z "$ENTRIES" ]]; then
        debug_log "No entries found in history"
        osascript -e 'display dialog "No valid entries in clipboard history." buttons {"OK"}'
        return
    fi

    # Show dialog with formatted entries
    debug_log "Running select_entry.applescript"
    CHOSEN=$(osascript "$SCRIPT_DIR/select_entry.applescript" "$ENTRIES")
    debug_log "User selected: $CHOSEN"

    if [[ -n "$CHOSEN" && "$CHOSEN" != "false" ]]; then
        # Extract timestamp from the chosen entry
        TIMESTAMP=$(echo "$CHOSEN" | sed 's/^"//' | sed 's/"$//' | cut -d'|' -f1 | xargs)
        debug_log "Extracted timestamp: $TIMESTAMP"

        # Get the full content
        debug_log "Running get_content.py"
        FULL_CONTENT=$(python3 "$SCRIPT_DIR/get_content.py" "$HISTORY_FILE" "$TIMESTAMP" 2>/tmp/get_content_error.log)
        debug_log "Retrieved content length: ${#FULL_CONTENT}"
        
        if [[ -n "$FULL_CONTENT" ]]; then
            debug_log "Copying content to clipboard"
            printf '%s' "$FULL_CONTENT" | pbcopy
            
            # Verify the clipboard content
            VERIFY_COPY=$(pbpaste)
            debug_log "Verifying clipboard content length: ${#VERIFY_COPY}"
            
            if [[ -n "$VERIFY_COPY" ]]; then
                debug_log "Content successfully copied to clipboard"
                osascript -e 'display notification "Copied to clipboard!"'
            else
                debug_log "Failed to copy to clipboard"
                ERROR_LOG=$(cat /tmp/get_content_error.log)
                debug_log "Error from get_content.py: $ERROR_LOG"
                osascript -e 'display dialog "Failed to copy to clipboard" buttons {"OK"}'
            fi
        else
            debug_log "No content retrieved from get_content.py"
            ERROR_LOG=$(cat /tmp/get_content_error.log)
            debug_log "Error from get_content.py: $ERROR_LOG"
            osascript -e 'display dialog "Failed to retrieve content" buttons {"OK"}'
        fi
    else
        debug_log "No selection made or selection cancelled"
    fi
}

# Initialize with valid JSON
if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
    echo '{"entries":[]}' > "$HISTORY_FILE"
fi

# Start clipboard listener in background
if [[ "$1" == "--start" ]]; then
    if [[ -f "$PID_FILE" ]]; then
        OLD_PID=$(cat "$PID_FILE")
        if ps -p $OLD_PID > /dev/null 2>&1; then
            echo "Clipboard listener is already running (PID: $OLD_PID)."
            exit 0
        fi
    fi

    # Background listener process
    (
        LAST_CONTENT=""
        while true; do
            CURRENT_CONTENT=$(pbpaste)
            if [[ "$CURRENT_CONTENT" != "$LAST_CONTENT" && -n "$CURRENT_CONTENT" ]]; then
                # Add new entry using Python
                timestamp=$(date "+%Y-%m-%d %H:%M:%S")
                content=$(echo "$CURRENT_CONTENT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().strip()))')
                python3 "$SCRIPT_DIR/add_entry.py" "$HISTORY_FILE" "$timestamp" "$content"
                LAST_CONTENT="$CURRENT_CONTENT"
            fi
            sleep 0.2
        done
    ) &
    echo $! > "$PID_FILE"
    echo "Clipboard listener started (PID: $(cat "$PID_FILE"))"
    exit 0
fi

# Show clipboard history
if [[ "$1" == "--show" ]]; then
    show_history
    exit 0
fi

# Stop the clipboard listener
if [[ "$1" == "--stop" ]]; then
    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")"
        rm "$PID_FILE"
        echo "Clipboard listener stopped."
    else
        echo "No clipboard listener is running."
    fi
    exit 0
fi