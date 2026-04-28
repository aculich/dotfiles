#!/usr/bin/env zsh

# Script to dump Cursor workspace information to timestamped files
# Extracts data from multiple sources for comprehensive state snapshot

# Create timestamp
timestamp=$(date +%Y-%m-%d_%H-%M-%S)

# Output directory: SNAPSHOT_DIR, or snapshots/workspace next to this script
script_dir="${0:a:h}"
output_dir="${SNAPSHOT_DIR:-${script_dir}/snapshots/workspace}"
mkdir -p "$output_dir"
base_name="cursor-workspace-${timestamp}"

# Output files
status_file="${output_dir}/${base_name}.txt"
json_file="${output_dir}/${base_name}.json"

echo "📸 Creating Cursor workspace snapshot..."
echo ""

# 1. Get cursor status
echo "[1/3] Getting cursor --status..."
cursor --status > "${status_file}"

# 2. Extract structured data from status output and storage.json
echo "[2/3] Extracting workspace data from storage and parsing windows..."
storage_json="${HOME}/Library/Application Support/Cursor/User/globalStorage/storage.json"

if [[ -f "$storage_json" ]]; then
    # Extract comprehensive workspace data using Python
    python3 <<EOF > "${json_file}"
import json
import sys
import re
from pathlib import Path

try:
    # Read storage.json
    with open('$storage_json', 'r') as f:
        data = json.load(f)
    
    # Read status output to extract window details
    with open('${status_file}', 'r') as f:
        status_text = f.read()
    
    output = {
        "timestamp": "${timestamp}",
        "windows": [],
        "folders": [],
        "recent_files": [],
        "workspace_stats": {}
    }
    
    # Extract window information from status output
    # Pattern: window [N] (filename — workspace-name)
    window_pattern = re.compile(r'window \[(\d+)\] \(([^)]+)\)')
    for match in window_pattern.finditer(status_text):
        window_num = match.group(1)
        window_info = match.group(2)
        
        # Parse "filename — workspace" or just "workspace"
        if ' — ' in window_info or ' - ' in window_info:
            separator = ' — ' if ' — ' in window_info else ' - '
            parts = window_info.split(separator, 1)
            current_file = parts[0].strip()
            workspace = parts[1].strip() if len(parts) > 1 else ''
        else:
            current_file = ''
            workspace = window_info.strip()
        
        output['windows'].append({
            "window_number": int(window_num),
            "workspace": workspace,
            "current_file": current_file
        })
    
    # Extract folders from storage.json
    if 'backupWorkspaces' in data and 'folders' in data['backupWorkspaces']:
        for folder in data['backupWorkspaces']['folders']:
            if 'folderUri' in folder:
                uri = folder['folderUri']
                # Convert file:// URI to path
                if uri.startswith('file://'):
                    path = uri[7:]  # Remove 'file://'
                    output['folders'].append(path)
    
    # Extract recent files from menubar data
    if 'lastKnownMenubarData' in data:
        menubar = data['lastKnownMenubarData']
        if 'menus' in menubar and 'File' in menubar['menus']:
            for item in menubar['menus']['File']['items']:
                if item.get('id') == 'submenuitem.MenubarRecentMenu':
                    if 'submenu' in item and 'items' in item['submenu']:
                        for recent_item in item['submenu']['items']:
                            if recent_item.get('id') == 'openRecentFile' and 'uri' in recent_item:
                                path = recent_item['uri'].get('path', '')
                                if path:
                                    output['recent_files'].append(path)
    
    # Extract workspace stats from status output
    # Pattern: Folder (name): N files
    folder_stats = {}
    in_workspace_stats = False
    for line in status_text.split('\n'):
        if 'Workspace Stats:' in line:
            in_workspace_stats = True
            continue
        if in_workspace_stats:
            if line.strip().startswith('Folder ('):
                match = re.match(r'\s*Folder \(([^)]+)\): (.+)', line)
                if match:
                    folder_name = match.group(1)
                    stats = match.group(2)
                    folder_stats[folder_name] = stats
    
    output['workspace_stats'] = folder_stats
    
    # Try to find open files per workspace from workspaceStorage
    workspace_storage_dir = Path.home() / 'Library/Application Support/Cursor/User/workspaceStorage'
    if workspace_storage_dir.exists():
        output['workspace_files'] = {}
        for workspace_dir in workspace_storage_dir.iterdir():
            if workspace_dir.is_dir():
                workspace_json = workspace_dir / 'workspace.json'
                if workspace_json.exists():
                    try:
                        with open(workspace_json, 'r') as f:
                            ws_data = json.load(f)
                            if 'folder' in ws_data:
                                folder_path = ws_data['folder']
                                # Try to get workspace name from path
                                if isinstance(folder_path, str) and folder_path.startswith('file://'):
                                    folder_path = folder_path[7:]
                                    workspace_name = Path(folder_path).name
                                    output['workspace_files'][workspace_name] = {
                                        'path': folder_path,
                                        'storage_id': workspace_dir.name
                                    }
                    except:
                        pass
    
    print(json.dumps(output, indent=2, sort_keys=True))
except Exception as e:
    import traceback
    print(json.dumps({"error": str(e), "traceback": traceback.format_exc()}), file=sys.stderr)
    sys.exit(1)
EOF
else
    echo '{"error": "storage.json not found"}' > "${json_file}"
fi

# 3. Get list of installed extensions
echo "[3/3] Getting installed extensions..."
extensions_file="${output_dir}/${base_name}-extensions.txt"
cursor --list-extensions --show-versions > "${extensions_file}"

echo ""
echo "✅ Snapshot complete!"
echo ""
echo "📁 Files created:"
echo "  Status:     ${status_file}"
echo "  JSON data:  ${json_file}"
echo "  Extensions: ${extensions_file}"
echo ""
echo "📊 Summary:"
if command -v jq &> /dev/null && [[ -f "${json_file}" ]]; then
    window_count=$(jq '.windows | length' "${json_file}" 2>/dev/null || echo 0)
    folder_count=$(jq '.folders | length' "${json_file}" 2>/dev/null || echo 0)
    recent_count=$(jq '.recent_files | length' "${json_file}" 2>/dev/null || echo 0)
    workspace_count=$(jq '.workspace_files | length' "${json_file}" 2>/dev/null || echo 0)
    echo "  Windows: ${window_count}"
    echo "  Folders tracked: ${folder_count}"
    echo "  Recent files: ${recent_count}"
    echo "  Workspace mappings: ${workspace_count}"
    echo "  Extensions: $(wc -l < "${extensions_file}" | tr -d ' ')"
    echo ""
    echo "💡 Tip: Use ./view-cursor-snapshots.sh to explore this snapshot"
else
    echo "  Windows: $(grep -c 'Window \[' "${status_file}" 2>/dev/null || echo 0)"
    echo "  Folders: $(grep -c 'Folder (' "${status_file}" 2>/dev/null || echo 0)"
    echo "  Extensions: $(wc -l < "${extensions_file}" | tr -d ' ')"
    echo ""
    echo "💡 Install jq for better summary: brew install jq"
fi
