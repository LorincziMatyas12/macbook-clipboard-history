#!/usr/bin/env python3
# AUTHOR: Lorinczi Matyas
# DESCRIPTION: This script adds a new entry to the clipboard history file.
# FILENAME: add_entry.py

import json
import sys
import os


def add_entry(history_file, timestamp, content):
    try:
        # Load existing data or create new structure
        if os.path.exists(history_file):
            with open(history_file, "r") as f:
                data = json.load(f)
        else:
            data = {"entries": []}

        # Parse the content as JSON
        try:
            content_json = json.loads(content)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON content: {e}", file=sys.stderr)
            return

        new_entry = {"timestamp": timestamp, "content": content_json}

        data["entries"].append(new_entry)

        # Write back to file
        with open(history_file, "w") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) > 3:
        add_entry(sys.argv[1], sys.argv[2], sys.argv[3])
    else:
        print(
            "Usage: add_entry.py <history_file> <timestamp> <content>", file=sys.stderr
        )
