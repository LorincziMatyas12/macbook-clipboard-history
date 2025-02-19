#!/bin/bash
HISTORY_FILE="$HOME/path/to/macos-clipboard-history/.env/.clipboard_history.json"
PID_FILE="$HOME/path/to/macos-clipboard-history/.env/.clipboard_listener_pid"

# Function to show history with timestamps
show_history() {
    # Validate JSON before showing history
    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        osascript -e 'display dialog "Clipboard history is empty." buttons {"OK"}'
        return
    fi

    # Process JSON and create formatted entries directly for AppleScript
    ENTRIES=$(python3 << EOF
import json
import sys
try:
    with open('$HISTORY_FILE', 'r') as f:
        data = json.load(f)
        entries = []
        for entry in data["entries"][-10:]: # Get last 10 entries
            content = entry["content"]
            # Create preview by taking first 30 chars and removing newlines
            preview = content.replace('\n', ' ').replace('"', "'")[:30]
            if len(content) > 30:
                preview += "..."
            # Create a clean entry for display, escape quotes for AppleScript
            formatted = f"{entry['timestamp']} | {preview}".replace('"', '\\"')
            entries.append(formatted)
        # Join entries with commas for AppleScript list
        print('","'.join(entries))
except Exception as e:
    print("")
EOF
)

    if [[ -z "$ENTRIES" ]]; then
        osascript -e 'display dialog "No valid entries in clipboard history." buttons {"OK"}'
        return
    fi

    # Show dialog with formatted entries
    CHOSEN=$(osascript << EOF
set entryList to {"$ENTRIES"}
set selectedItem to choose from list entryList with prompt "Select clipboard entry:" default items {}
return selectedItem
EOF
)

    if [[ -n "$CHOSEN" && "$CHOSEN" != "false" ]]; then
        # Extract timestamp from the chosen entry
        TIMESTAMP=$(echo "$CHOSEN" | cut -d'|' -f1 | xargs)
        # Get the full content
        FULL_CONTENT=$(python3 << EOF
import json
try:
    with open('$HISTORY_FILE', 'r') as f:
        data = json.load(f)
        timestamp = '$TIMESTAMP'
        for entry in data['entries']:
            if entry['timestamp'] == timestamp:
                print(entry['content'])
                break
except Exception as e:
    print("")
EOF
)
        if [[ -n "$FULL_CONTENT" ]]; then
            echo -n "$FULL_CONTENT" | pbcopy
            osascript -e 'display notification "Copied to clipboard!"'
        fi
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
                python3 << EOF
import json
import os
try:
    with open('$HISTORY_FILE', 'r') as f:
        data = json.load(f)
except:
    data = {"entries": []}
new_entry = {
    "timestamp": "$timestamp",
    "content": ${content}
}
data["entries"].append(new_entry)
with open('$HISTORY_FILE', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
EOF
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