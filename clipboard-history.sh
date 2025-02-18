#!/bin/bash

HISTORY_FILE="$HOME/.clipboard_history"
PID_FILE="$HOME/.clipboard_listener_pid"

# Ensure the history file exists
touch "$HISTORY_FILE"

# Function to listen for Command+C and save clipboard content
clipboard_listener() {
    LAST_CONTENT=""
    while true; do
        CURRENT_CONTENT=$(pbpaste)
        if [[ "$CURRENT_CONTENT" != "$LAST_CONTENT" && -n "$CURRENT_CONTENT" ]]; then
            echo "$CURRENT_CONTENT" >> "$HISTORY_FILE"
            LAST_CONTENT="$CURRENT_CONTENT"
        fi
        sleep 0.2  # Adjust for responsiveness
    done
}

show_history() {
    if [[ ! -s "$HISTORY_FILE" ]]; then
        osascript -e 'display dialog "Clipboard history is empty." buttons {"OK"}'
    else
        # Read the last 10 clipboard entries and format them correctly
        HISTORY=$(tail -n 10 "$HISTORY_FILE" | awk '{gsub(/"/, "\\\""); print "\"" $0 "\""}' ORS=", ")
        
        # Remove trailing comma
        HISTORY=${HISTORY%, }

        # Run AppleScript safely
        CHOSEN=$(osascript -e "try
            choose from list {$HISTORY} with prompt \"Select clipboard entry:\" default items {}
        on error
            return \"\"
        end try")

        # Copy the selected item to clipboard if it's not empty
        if [[ -n "$CHOSEN" && "$CHOSEN" != "false" ]]; then
            echo -n "$CHOSEN" | pbcopy  # Copy selection to clipboard
            osascript -e 'display notification "Copied to clipboard!"'
        fi
    fi
}

# Start clipboard listener in background
if [[ "$1" == "--start" ]]; then
    # Check if the process is already running
    if [[ -f "$PID_FILE" ]]; then
        OLD_PID=$(cat "$PID_FILE")
        if ps -p $OLD_PID > /dev/null 2>&1; then
            echo "Clipboard listener is already running (PID: $OLD_PID)."
            exit 0
        fi
    fi

    # Start the listener
    clipboard_listener &
    echo $! > "$PID_FILE"
    echo "Clipboard listener started (PID: $(cat "$PID_FILE"))"
    exit 0
fi

# Show clipboard history on demand
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
