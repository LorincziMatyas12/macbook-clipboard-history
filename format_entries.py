#!/usr/bin/env python3
# AUTHOR: Lorinczi Matyas
# DESCRIPTION: This script reads the clipboard history file and returns the last 10 entries in a format that can be used by AppleScript.
# FILENAME: format_entries.py

import json
import sys
import os


def format_entries(history_file):
    try:
        # Check if file exists
        if not os.path.exists(history_file):
            print(f"Error: History file not found: {history_file}", file=sys.stderr)
            return ""

        with open(history_file, "r") as f:
            data = json.load(f)

        entries = []
        for entry in reversed(
            data["entries"][-10:]
        ):  # Get last 10 entries, newest first
            content = entry["content"]
            # Create preview by taking first 30 chars and removing newlines
            preview = content.replace("\n", " ").replace('"', "'")[:30]
            if len(content) > 30:
                preview += "..."
            # Create a clean entry for display, escape quotes for AppleScript
            formatted = f"{entry['timestamp']} | {preview}".replace('"', '\\"')
            entries.append(formatted)

        if entries:
            # Join entries with commas for AppleScript list
            print('","'.join(entries))
        else:
            print(f"Error: No entries found in history file", file=sys.stderr)

    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in history file: {e}", file=sys.stderr)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        format_entries(sys.argv[1])
    else:
        print("Usage: format_entries.py <history_file>", file=sys.stderr)
