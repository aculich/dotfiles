#!/bin/bash
# Simple script to search Chrome session files for potential form data
# This searches binary session files for readable text content

set -e

CHROME_BASE="$HOME/Library/Application Support/Google/Chrome"
OUTPUT_FILE="$HOME/Desktop/recovered-form-data.txt"

echo "🔍 Searching Chrome session files for potential form data..."
echo "============================================================"
echo ""

# Function to search a session file for text
search_session_file() {
    local file="$1"
    local profile_name="$2"
    
    echo "  Checking: $(basename "$file")"
    
    # Use strings to extract readable text, then filter for longer content
    strings "$file" 2>/dev/null | \
        grep -E '.{100,}' | \
        grep -vE '^(https?://|chrome-extension://|data:)' | \
        awk 'length($0) > 200 && NF > 20' | \
        head -20 | \
        while IFS= read -r line; do
            echo "[$profile_name] $(basename "$file"): $line" >> "$OUTPUT_FILE"
        done
}

# Clear output file
> "$OUTPUT_FILE"

# Search Default profile
if [ -d "$CHROME_BASE/Default/Sessions" ]; then
    echo "📁 Searching Default profile..."
    for file in "$CHROME_BASE/Default/Sessions"/Apps_* "$CHROME_BASE/Default/Sessions"/Session_*; do
        if [ -f "$file" ]; then
            search_session_file "$file" "Default"
        fi
    done
    echo ""
fi

# Search numbered profiles
for profile_dir in "$CHROME_BASE"/Profile\ *; do
    if [ -d "$profile_dir/Sessions" ]; then
        profile_name=$(basename "$profile_dir")
        echo "📁 Searching $profile_name..."
        for file in "$profile_dir/Sessions"/Apps_* "$profile_dir/Sessions"/Session_*; do
            if [ -f "$file" ]; then
                search_session_file "$file" "$profile_name"
            fi
        done
        echo ""
    fi
done

# Count results
result_count=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo "0")

echo "============================================================"
echo "📊 Found $result_count potential text strings"
echo "💾 Results saved to: $OUTPUT_FILE"
echo ""
echo "💡 Tips:"
echo "   • Look for your text in the output file"
echo "   • Session Storage data is usually cleared when Chrome closes"
echo "   • For deeper access, install leveldb and use the Python script"
echo ""

if [ "$result_count" -gt 0 ]; then
    echo "Preview of first few results:"
    echo "---"
    head -5 "$OUTPUT_FILE"
    echo "..."
fi

