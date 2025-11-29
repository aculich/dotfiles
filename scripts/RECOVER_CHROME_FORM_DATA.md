# Recovering Unsaved Form Data from Chrome Apps

## The Challenge

When you close a Chrome app (like CGPT), **Session Storage** is typically cleared immediately. Form data in textareas/inputs is usually stored in Session Storage, which means it's often lost when the app closes.

However, there are several places where your data might still exist:

## Where Form Data Might Be Stored

1. **Session Storage** (LevelDB) - ⚠️ Usually cleared on close
2. **Local Storage** (LevelDB) - ✅ Persists, but form data rarely stored here
3. **IndexedDB** - ✅ Persists, may contain app state
4. **Session Files** - ✅ May contain form state if Chrome crashed
5. **Chrome's Session Restore** - ✅ May have recent tabs/windows

## Recovery Methods

### Method 1: Check Chrome's Recently Closed (Easiest)

1. Open Chrome normally (not the app)
2. Press `Cmd+Shift+T` to restore recently closed tabs
3. Or go to History → Recently Closed
4. Look for the ChatGPT tab - it might restore with your text

### Method 2: Search Session Files (Simple Script)

Run the simple bash script:
```bash
./scripts/recover-chrome-form-simple.sh
```

This searches binary session files for readable text. Results saved to `~/Desktop/recovered-form-data.txt`

### Method 3: Deep LevelDB Access (Most Comprehensive)

For full access to Session Storage, Local Storage, and IndexedDB:

#### Option A: Python with plyvel

1. Install LevelDB:
   ```bash
   brew install leveldb
   ```

2. Install plyvel in a virtual environment:
   ```bash
   python3 -m venv ~/venv-chrome-recovery
   source ~/venv-chrome-recovery/bin/activate
   pip install plyvel
   ```

3. Run the Python script:
   ```bash
   python3 scripts/recover-chrome-form-data.py
   ```

#### Option B: Node.js with leveldown

1. Install leveldown:
   ```bash
   npm install -g leveldown levelup
   ```

2. Run the Node.js script:
   ```bash
   node scripts/recover-chrome-form-data-node.js
   ```

### Method 4: Manual Chrome Data Inspection

Your CGPT app data is located at:
```
~/Library/Application Support/Google/Chrome/-/Web Applications/_crx_cadlkienfkclaiaibeoongdcgmdikeeg
```

The app uses Profile 1 or Default profile. Check:
- `Profile 1/Session Storage/` - Session Storage LevelDB
- `Profile 1/Local Storage/leveldb/` - Local Storage LevelDB  
- `Profile 1/IndexedDB/https_chatgpt.com_0.indexeddb.leveldb/` - IndexedDB

## Important Notes

⚠️ **Session Storage is ephemeral** - It's designed to be cleared when the session ends. If you closed the app normally, this data is likely gone.

✅ **Local Storage and IndexedDB persist** - But most form data isn't stored here unless the app specifically saves it.

💡 **Best Practice**: Use browser extensions or apps that auto-save drafts, or copy important text before closing.

## If Data is Found

The scripts will:
- Search all Chrome profiles
- Extract potential form content
- Save results to `~/Desktop/recovered-form-data.json` or `.txt`
- Show previews of found content

## Your Specific App

- **App Name**: CGPT
- **App ID**: `cadlkienfkclaiaibeoongdcgmdikeeg`
- **URL**: `https://chatgpt.com/`
- **Data Directory**: `~/Library/Application Support/Google/Chrome/-/Web Applications/_crx_cadlkienfkclaiaibeoongdcgmdikeeg`

## Quick Check

Try this first - it's the easiest:
1. Open Chrome (regular browser)
2. Press `Cmd+Shift+T` multiple times to restore closed tabs
3. Check if your ChatGPT session is there

If that doesn't work, proceed with the scripts above.

