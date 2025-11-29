#!/usr/bin/env python3
"""
Recover unsaved form data from Chrome app sessions.
Searches Session Storage, Local Storage, and IndexedDB for form content.
"""

import os
import sys
import json
import re
from pathlib import Path

try:
    import plyvel
except ImportError:
    print("Installing plyvel (this may take a moment)...")
    import subprocess
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "plyvel", "--user", "--quiet"])
    except:
        # Try with --break-system-packages as fallback
        subprocess.check_call([sys.executable, "-m", "pip", "install", "plyvel", "--user", "--break-system-packages", "--quiet"])
    import plyvel


def read_leveldb(db_path):
    """Read all key-value pairs from a LevelDB database."""
    try:
        db = plyvel.DB(db_path, create_if_missing=False)
        data = {}
        for key, value in db:
            try:
                # Try to decode as UTF-8
                key_str = key.decode('utf-8', errors='ignore')
                value_str = value.decode('utf-8', errors='ignore')
                data[key_str] = value_str
            except:
                # If decoding fails, store as hex
                data[key.hex()] = value.hex()
        db.close()
        return data
    except Exception as e:
        return None


def search_for_text(data, search_terms=None):
    """Search through data for text content that might be form data."""
    results = []
    
    if isinstance(data, dict):
        for key, value in data.items():
            if isinstance(value, str):
                # Look for longer text strings (likely form content)
                if len(value) > 50:
                    # Check if it contains form-like content
                    if any(term in value.lower() for term in (search_terms or [''])):
                        results.append({
                            'key': key,
                            'value': value,
                            'length': len(value)
                        })
            elif isinstance(value, dict):
                results.extend(search_for_text(value, search_terms))
    elif isinstance(value, list):
        for item in value:
            results.extend(search_for_text(item, search_terms))
    
    return results


def find_chrome_profiles():
    """Find all Chrome profile directories."""
    chrome_base = Path.home() / "Library/Application Support/Google/Chrome"
    profiles = []
    
    if chrome_base.exists():
        # Default profile
        if (chrome_base / "Default").exists():
            profiles.append(chrome_base / "Default")
        
        # Numbered profiles
        for item in chrome_base.iterdir():
            if item.is_dir() and item.name.startswith("Profile "):
                profiles.append(item)
    
    return profiles


def search_session_storage(profile_path):
    """Search Session Storage LevelDB files."""
    session_storage = profile_path / "Session Storage"
    results = []
    
    if not session_storage.exists():
        return results
    
    # Session Storage uses LevelDB
    try:
        db = plyvel.DB(str(session_storage), create_if_missing=False)
        for key, value in db:
            try:
                key_str = key.decode('utf-8', errors='ignore')
                value_str = value.decode('utf-8', errors='ignore')
                
                # Look for chatgpt.com related entries
                if 'chatgpt' in key_str.lower() or 'chatgpt' in value_str.lower():
                    # Look for longer text that might be form content
                    if len(value_str) > 50:
                        results.append({
                            'source': 'Session Storage',
                            'key': key_str,
                            'value': value_str[:500],  # First 500 chars
                            'full_length': len(value_str)
                        })
            except:
                pass
        db.close()
    except Exception as e:
        pass
    
    return results


def search_local_storage(profile_path):
    """Search Local Storage LevelDB files."""
    local_storage = profile_path / "Local Storage" / "leveldb"
    results = []
    
    if not local_storage.exists():
        return results
    
    try:
        db = plyvel.DB(str(local_storage), create_if_missing=False)
        for key, value in db:
            try:
                key_str = key.decode('utf-8', errors='ignore')
                value_str = value.decode('utf-8', errors='ignore')
                
                # Look for chatgpt.com related entries
                if 'chatgpt' in key_str.lower() or 'chatgpt' in value_str.lower():
                    if len(value_str) > 50:
                        results.append({
                            'source': 'Local Storage',
                            'key': key_str,
                            'value': value_str[:500],
                            'full_length': len(value_str)
                        })
            except:
                pass
        db.close()
    except Exception as e:
        pass
    
    return results


def search_indexeddb(profile_path):
    """Search IndexedDB for chatgpt.com."""
    indexeddb_base = profile_path / "IndexedDB"
    results = []
    
    if not indexeddb_base.exists():
        return results
    
    # Look for chatgpt.com IndexedDB
    chatgpt_db = indexeddb_base / "https_chatgpt.com_0.indexeddb.leveldb"
    
    if chatgpt_db.exists():
        try:
            db = plyvel.DB(str(chatgpt_db), create_if_missing=False)
            for key, value in db:
                try:
                    key_str = key.decode('utf-8', errors='ignore')
                    value_str = value.decode('utf-8', errors='ignore')
                    
                    # Look for longer text content
                    if len(value_str) > 50:
                        # Check if it looks like form/textarea content
                        if any(char in value_str for char in ['\n', '.', '!', '?']) and len(value_str.split()) > 10:
                            results.append({
                                'source': 'IndexedDB (chatgpt.com)',
                                'key': key_str[:100],
                                'value': value_str[:1000],
                                'full_length': len(value_str)
                            })
                except:
                    pass
            db.close()
        except Exception as e:
            pass
    
    return results


def main():
    print("🔍 Searching for unsaved form data from CGPT Chrome app...")
    print("=" * 60)
    
    all_results = []
    profiles = find_chrome_profiles()
    
    if not profiles:
        print("❌ No Chrome profiles found!")
        return
    
    print(f"Found {len(profiles)} Chrome profile(s)\n")
    
    for profile_path in profiles:
        print(f"📁 Searching profile: {profile_path.name}")
        
        # Search Session Storage
        print("  → Checking Session Storage...")
        session_results = search_session_storage(profile_path)
        all_results.extend(session_results)
        print(f"    Found {len(session_results)} potential matches")
        
        # Search Local Storage
        print("  → Checking Local Storage...")
        local_results = search_local_storage(profile_path)
        all_results.extend(local_results)
        print(f"    Found {len(local_results)} potential matches")
        
        # Search IndexedDB
        print("  → Checking IndexedDB...")
        indexeddb_results = search_indexeddb(profile_path)
        all_results.extend(indexeddb_results)
        print(f"    Found {len(indexeddb_results)} potential matches")
        
        print()
    
    print("=" * 60)
    print(f"\n📊 Total potential matches: {len(all_results)}\n")
    
    if all_results:
        print("🔎 Potential form data found:\n")
        for i, result in enumerate(all_results, 1):
            print(f"[{i}] Source: {result['source']}")
            print(f"    Key: {result['key'][:100]}")
            print(f"    Length: {result['full_length']} characters")
            print(f"    Preview: {result['value'][:200]}...")
            print()
        
        # Save to file
        output_file = Path.home() / "Desktop" / "recovered-form-data.json"
        with open(output_file, 'w') as f:
            json.dump(all_results, f, indent=2)
        print(f"💾 Full results saved to: {output_file}")
    else:
        print("❌ No form data found. The data may have been cleared when the app closed.")
        print("\n💡 Note: Session Storage is typically cleared when the browser/app closes.")
        print("   Local Storage and IndexedDB data should persist, but form data")
        print("   in textareas/inputs is usually only in Session Storage.")


if __name__ == "__main__":
    main()

