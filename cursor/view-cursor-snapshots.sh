#!/usr/bin/env zsh

# Helper script to view and compare Cursor workspace snapshots

script_dir="${0:a:h}"
snapshot_dir="${SNAPSHOT_DIR:-${script_dir}/snapshots/workspace}"

# List all snapshots
snapshots=(${snapshot_dir}/cursor-workspace-*.json(N))

if [[ ${#snapshots[@]} -eq 0 ]]; then
    echo "❌ No snapshots found in ${snapshot_dir}"
    echo "Run ./dump-cursor-windows.sh to create a snapshot first."
    exit 1
fi

echo "📚 Available snapshots:"
echo ""
for i in {1..${#snapshots[@]}}; do
    snapshot="${snapshots[$i]}"
    basename="${snapshot:t:r}"
    timestamp="${basename#cursor-workspace-}"
    
    if command -v jq &> /dev/null; then
        folder_count=$(jq '.folders | length' "$snapshot" 2>/dev/null || echo "?")
        recent_count=$(jq '.recent_files | length' "$snapshot" 2>/dev/null || echo "?")
        echo "  [$i] $timestamp (${folder_count} folders, ${recent_count} recent files)"
    else
        echo "  [$i] $timestamp"
    fi
done

echo ""
echo "Commands:"
echo "  ./view-cursor-snapshots.sh list          - Show this list"
echo "  ./view-cursor-snapshots.sh view N        - View snapshot N in detail"
echo "  ./view-cursor-snapshots.sh windows N     - List all open windows from snapshot N"
echo "  ./view-cursor-snapshots.sh folders N     - List folders from snapshot N"
echo "  ./view-cursor-snapshots.sh recent N      - List recent files from snapshot N"
echo "  ./view-cursor-snapshots.sh stats N       - Show workspace stats from snapshot N"
echo "  ./view-cursor-snapshots.sh diff N1 N2    - Compare two snapshots"
echo "  ./view-cursor-snapshots.sh latest        - View latest snapshot"
echo ""

# Handle commands
cmd="${1:-list}"
case "$cmd" in
    view)
        idx="${2:-0}"
        if [[ $idx -gt 0 && $idx -le ${#snapshots[@]} ]]; then
            snapshot="${snapshots[$idx]}"
            echo "📄 Viewing: ${snapshot:t}"
            echo ""
            if command -v jq &> /dev/null; then
                jq . "$snapshot"
            else
                cat "$snapshot"
            fi
        else
            echo "❌ Invalid snapshot number: $idx"
            exit 1
        fi
        ;;
    windows)
        idx="${2:-0}"
        if [[ $idx -gt 0 && $idx -le ${#snapshots[@]} ]]; then
            snapshot="${snapshots[$idx]}"
            echo "🪟 Windows from: ${snapshot:t}"
            echo ""
            if command -v jq &> /dev/null; then
                jq -r '.windows[] | "[\(.window_number)] \(.current_file) — \(.workspace)"' "$snapshot"
            else
                echo "⚠️  jq not installed - install with: brew install jq"
            fi
        else
            echo "❌ Invalid snapshot number: $idx"
            exit 1
        fi
        ;;
    folders)
        idx="${2:-0}"
        if [[ $idx -gt 0 && $idx -le ${#snapshots[@]} ]]; then
            snapshot="${snapshots[$idx]}"
            echo "📁 Folders from: ${snapshot:t}"
            echo ""
            if command -v jq &> /dev/null; then
                jq -r '.folders[]' "$snapshot" | sort
            else
                echo "⚠️  jq not installed - install with: brew install jq"
            fi
        else
            echo "❌ Invalid snapshot number: $idx"
            exit 1
        fi
        ;;
    recent)
        idx="${2:-0}"
        if [[ $idx -gt 0 && $idx -le ${#snapshots[@]} ]]; then
            snapshot="${snapshots[$idx]}"
            echo "📝 Recent files from: ${snapshot:t}"
            echo ""
            if command -v jq &> /dev/null; then
                jq -r '.recent_files[]' "$snapshot"
            else
                echo "⚠️  jq not installed - install with: brew install jq"
            fi
        else
            echo "❌ Invalid snapshot number: $idx"
            exit 1
        fi
        ;;
    stats)
        idx="${2:-0}"
        if [[ $idx -gt 0 && $idx -le ${#snapshots[@]} ]]; then
            snapshot="${snapshots[$idx]}"
            echo "📊 Workspace stats from: ${snapshot:t}"
            echo ""
            if command -v jq &> /dev/null; then
                echo "Workspace file counts and types:"
                jq -r '.workspace_stats | to_entries[] | "\n\(.key):\n  \(.value)"' "$snapshot"
            else
                echo "⚠️  jq not installed - install with: brew install jq"
            fi
        else
            echo "❌ Invalid snapshot number: $idx"
            exit 1
        fi
        ;;
    diff)
        idx1="${2:-0}"
        idx2="${3:-0}"
        if [[ $idx1 -gt 0 && $idx1 -le ${#snapshots[@]} && $idx2 -gt 0 && $idx2 -le ${#snapshots[@]} ]]; then
            snapshot1="${snapshots[$idx1]}"
            snapshot2="${snapshots[$idx2]}"
            echo "🔍 Comparing snapshots:"
            echo "  Old: ${snapshot1:t}"
            echo "  New: ${snapshot2:t}"
            echo ""
            
            if command -v jq &> /dev/null; then
                echo "New folders:"
                comm -13 <(jq -r '.folders[]' "$snapshot1" | sort) <(jq -r '.folders[]' "$snapshot2" | sort)
                echo ""
                echo "Removed folders:"
                comm -23 <(jq -r '.folders[]' "$snapshot1" | sort) <(jq -r '.folders[]' "$snapshot2" | sort)
            else
                echo "⚠️  jq not installed - install with: brew install jq"
            fi
        else
            echo "❌ Invalid snapshot numbers: $idx1, $idx2"
            exit 1
        fi
        ;;
    latest)
        if [[ ${#snapshots[@]} -gt 0 ]]; then
            latest="${snapshots[-1]}"
            echo "📄 Latest snapshot: ${latest:t}"
            echo ""
            if command -v jq &> /dev/null; then
                jq . "$latest"
            else
                cat "$latest"
            fi
        fi
        ;;
    list|*)
        # Already shown above
        ;;
esac
