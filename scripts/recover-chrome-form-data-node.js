#!/usr/bin/env node
/**
 * Recover unsaved form data from Chrome app sessions using Node.js
 * Searches Session Storage, Local Storage, and IndexedDB for form content
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

// Check if leveldown is available
let leveldown;
try {
  leveldown = require('leveldown');
} catch (e) {
  console.log('⚠️  leveldown not installed. Attempting to install...');
  try {
    execSync('npm install -g leveldown', { stdio: 'inherit' });
    leveldown = require('leveldown');
  } catch (err) {
    console.error('❌ Failed to install leveldown. Please install manually:');
    console.error('   npm install -g leveldown');
    console.error('\nAlternatively, install leveldb via Homebrew and use the Python script.');
    process.exit(1);
  }
}

function findChromeProfiles() {
  const chromeBase = path.join(os.homedir(), 'Library/Application Support/Google/Chrome');
  const profiles = [];
  
  if (fs.existsSync(chromeBase)) {
    // Default profile
    const defaultPath = path.join(chromeBase, 'Default');
    if (fs.existsSync(defaultPath)) {
      profiles.push({ name: 'Default', path: defaultPath });
    }
    
    // Numbered profiles
    const items = fs.readdirSync(chromeBase);
    for (const item of items) {
      if (item.startsWith('Profile ')) {
        const profilePath = path.join(chromeBase, item);
        if (fs.statSync(profilePath).isDirectory()) {
          profiles.push({ name: item, path: profilePath });
        }
      }
    }
  }
  
  return profiles;
}

function searchLevelDB(dbPath, sourceName) {
  const results = [];
  
  if (!fs.existsSync(dbPath)) {
    return results;
  }
  
  try {
    const db = leveldown(dbPath);
    db.open((err) => {
      if (err) {
        console.error(`Error opening ${dbPath}: ${err.message}`);
        return results;
      }
    });
    
    // Note: This is a simplified version. Full implementation would need
    // to iterate through all keys, which requires levelup wrapper
    console.log(`  ⚠️  Direct LevelDB access requires levelup wrapper`);
    console.log(`  → Consider using the Python script with plyvel instead`);
    
    db.close(() => {});
  } catch (e) {
    // LevelDB access failed
  }
  
  return results;
}

function searchSessionStorage(profilePath) {
  const sessionStorage = path.join(profilePath, 'Session Storage');
  return searchLevelDB(sessionStorage, 'Session Storage');
}

function searchLocalStorage(profilePath) {
  const localStorage = path.join(profilePath, 'Local Storage', 'leveldb');
  return searchLevelDB(localStorage, 'Local Storage');
}

function searchIndexedDB(profilePath) {
  const indexeddbBase = path.join(profilePath, 'IndexedDB');
  const chatgptDB = path.join(indexeddbBase, 'https_chatgpt.com_0.indexeddb.leveldb');
  
  if (fs.existsSync(chatgptDB)) {
    return searchLevelDB(chatgptDB, 'IndexedDB (chatgpt.com)');
  }
  
  return [];
}

function searchSessionFiles(profilePath) {
  const sessionsDir = path.join(profilePath, 'Sessions');
  const results = [];
  
  if (!fs.existsSync(sessionsDir)) {
    return results;
  }
  
  // Get most recent session files
  const files = fs.readdirSync(sessionsDir)
    .map(f => ({
      name: f,
      path: path.join(sessionsDir, f),
      mtime: fs.statSync(path.join(sessionsDir, f)).mtime
    }))
    .sort((a, b) => b.mtime - a.mtime)
    .slice(0, 5); // Check 5 most recent
  
  for (const file of files) {
    try {
      const content = fs.readFileSync(file.path);
      // Look for readable text that might be form data
      const text = content.toString('utf8', 0, Math.min(content.length, 100000));
      
      // Search for longer text strings (potential form content)
      const matches = text.match(/[a-zA-Z0-9\s.,!?;:]{100,}/g);
      if (matches) {
        for (const match of matches) {
          if (match.length > 200 && match.split(/\s+/).length > 20) {
            results.push({
              source: `Session File: ${file.name}`,
              value: match.substring(0, 500),
              full_length: match.length,
              file: file.name
            });
          }
        }
      }
    } catch (e) {
      // Binary file or read error
    }
  }
  
  return results;
}

function main() {
  console.log('🔍 Searching for unsaved form data from CGPT Chrome app...');
  console.log('='.repeat(60));
  
  const profiles = findChromeProfiles();
  
  if (profiles.length === 0) {
    console.log('❌ No Chrome profiles found!');
    return;
  }
  
  console.log(`Found ${profiles.length} Chrome profile(s)\n`);
  
  const allResults = [];
  
  for (const profile of profiles) {
    console.log(`📁 Searching profile: ${profile.name}`);
    
    // Search session files (most likely to have recent data)
    console.log('  → Checking Session Files...');
    const sessionResults = searchSessionFiles(profile.path);
    allResults.push(...sessionResults);
    console.log(`    Found ${sessionResults.length} potential matches`);
    
    // Note: LevelDB access is complex, recommending Python approach
    console.log('  → LevelDB access requires additional setup');
    console.log('    (Session Storage, Local Storage, IndexedDB)');
    console.log('    Consider using the Python script for full access.\n');
  }
  
  console.log('='.repeat(60));
  console.log(`\n📊 Total potential matches: ${allResults.length}\n`);
  
  if (allResults.length > 0) {
    console.log('🔎 Potential form data found:\n');
    allResults.forEach((result, i) => {
      console.log(`[${i + 1}] Source: ${result.source}`);
      if (result.file) {
        console.log(`    File: ${result.file}`);
      }
      console.log(`    Length: ${result.full_length} characters`);
      console.log(`    Preview: ${result.value.substring(0, 200)}...`);
      console.log();
    });
    
    // Save to file
    const outputFile = path.join(os.homedir(), 'Desktop', 'recovered-form-data.json');
    fs.writeFileSync(outputFile, JSON.stringify(allResults, null, 2));
    console.log(`💾 Results saved to: ${outputFile}`);
  } else {
    console.log('❌ No form data found in session files.');
    console.log('\n💡 Important notes:');
    console.log('   • Session Storage is typically cleared when the app closes');
    console.log('   • Form data in textareas/inputs is usually only in Session Storage');
    console.log('   • For deeper LevelDB access, use the Python script with plyvel');
    console.log('   • You may need to check if Chrome has a "Recently Closed" feature');
  }
}

main();

