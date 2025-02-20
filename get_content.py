#!/usr/bin/env python3
# AUTHOR: Lorinczi Matyas
# DESCRIPTION: This script reads the clipboard history file and returns the content of an entry by timestamp.
# FILENAME: get_content.py

import json
import sys
import os


def get_content(history_file, timestamp):
    try:
        # Check if file exists
        if not os.path.exists(history_file):
            print(f"Error: History file not found: {history_file}", file=sys.stderr)
            return ""

        with open(history_file, "r") as f:
            data = json.load(f)

        for entry in data["entries"]:
            if entry["timestamp"].strip() == timestamp.strip():
                # Ensure content is a string and escape any quotes
                content = str(entry["content"])
                # Print without newline at the end
                sys.stdout.write(content)
                sys.stdout.flush()
                return

        print(f"Error: No entry found for timestamp: {timestamp}", file=sys.stderr)

    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in history file: {e}", file=sys.stderr)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) > 2:
        get_content(sys.argv[1], sys.argv[2])
    else:
        print("Usage: get_content.py <history_file> <timestamp>", file=sys.stderr)
