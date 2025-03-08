## SpecStory

## macOS Sequoia CLI Settings Configuration (3/8/2025, 9:54:19 AM)

_**User**_

give me the mac cli `defaults write` or other cli commands that I need to turn off or change the mac settings pictured for my macOS Sequoia 15.2

---

_**Assistant**_

Based on the macOS settings shown in the image, I'll provide the relevant `defaults write` commands to configure these settings via the command line. I'll break them down based on what's shown in the screenshot:

1. To disable "Show Input menu in menu bar":
```bash
defaults write com.apple.TextInputMenu visible -bool false
```

2. For text input settings:
```bash
# Turn off "Correct spelling automatically"
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

# Turn off "Capitalize words automatically"
defaults write -g NSAutomaticCapitalizationEnabled -bool false

# Turn off "Show inline predictive text"
defaults write -g NSAutomaticTextCompletionEnabled -bool false

# Turn off "Add period with double-space"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
```

3. For smart quotes and dashes (which are shown as enabled in the image, but if you want to disable them):
```bash
# Turn off smart quotes
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# Turn off smart dashes
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
```

After running these commands, you'll need to either restart your applications or log out and back in for all changes to take effect. You can do this with:

```bash
killall SystemUIServer
```

Note: Some of these settings might require you to restart the specific applications you're using for the changes to take effect. If you want to verify any of these settings, you can use `defaults read` with the same domain, for example:

```bash
defaults read -g NSAutomaticSpellingCorrectionEnabled
```

To revert any of these changes, you can either use the GUI or replace `-bool false` with `-bool true` in the corresponding command.

---

_**User**_

add those commands as comments to the end of @keybindings.json 


---

_**Assistant**_

I'll add these commands as comments to the end of your keybindings.json file.

---

_****_

```diff
  // defaults write -g KeyRepeat -int 1                                            // set keyboard repeat rate to fastest
  // defaults write -g InitialKeyRepeat -int 10                                    // set key repeat delay to shortest
+ 
+ // Input Menu and Text Settings:
+ // defaults write com.apple.TextInputMenu visible -bool false                    // hide input menu from menu bar
+ // defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false           // disable automatic spelling correction
+ // defaults write -g NSAutomaticCapitalizationEnabled -bool false               // disable automatic capitalization
+ // defaults write -g NSAutomaticTextCompletionEnabled -bool false               // disable inline predictive text
+ // defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false // disable period on double-space
+ // defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false            // disable smart quotes
+ // defaults write -g NSAutomaticDashSubstitutionEnabled -bool false             // disable smart dashes
+ 
+ // After changing settings:
+ // killall SystemUIServer                                                        // restart UI to apply changes
  
  
```

---

_****_

I've added all the macOS defaults commands as comments at the end of your keybindings.json file. The commands are organized by category and include explanatory comments. Each command is aligned and commented with its purpose for easy reference. You can now easily copy and paste these commands into your terminal when needed.

The commands are grouped into:
1. The existing keyboard settings you already had
2. Input menu and text settings from the screenshot
3. A reminder to restart the UI server after making changes

All commands are properly formatted and aligned for readability. You can copy any of these commands directly from the file and run them in your terminal when you want to apply these settings.

---

_**User**_

is there a cli equiv to openning the system settings to that macos settings dialog for these settings? maybe with `open` or some other simple one-liner?

---

_**Assistant**_

Yes! You can directly open the specific keyboard settings panel using the `open` command with the appropriate URL scheme. Here's the command:

---

_****_

```diff
  
  // Input Menu and Text Settings:
- // 
+ // open "x-apple.systempreferences:com.apple.Keyboard-Settings.textinput"        // open Text Input settings panel
+ 
  // defaults write com.apple.TextInputMenu visible -bool false                    // hide input menu from menu bar
  // defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false           // disable automatic spelling correction
```

---

_****_

I've added the command that will directly open the Text Input settings panel in System Settings. You can copy and run this command in your terminal:

```bash
open "x-apple.systempreferences:com.apple.Keyboard-Settings.textinput"
```

This command uses macOS's URL scheme to open System Settings directly to the Text Input panel, which is the same panel shown in your screenshot. It's a convenient way to quickly access these settings without having to navigate through the System Settings UI manually.

---

_**User**_

and another one specifically to go to language input methods?

---

_**Assistant**_

Yes! Let me add the command to open the Language & Region settings panel where input methods are configured.

---

_****_

```diff
  // Input Menu and Text Settings:
  // open "x-apple.systempreferences:com.apple.Keyboard-Settings.textinput"        // open Text Input settings panel
+ // open "x-apple.systempreferences:com.apple.Language-Region-Settings"           // open Language & Region settings
  
  // defaults write com.apple.TextInputMenu visible -bool false                    // hide input menu from menu bar
```

---

_****_

I've added the command that will directly open the Language & Region settings panel. You can copy and run this command in your terminal:

```bash
open "x-apple.systempreferences:com.apple.Language-Region-Settings"
```

This will take you directly to the Language & Region panel in System Settings where you can configure input methods, preferred languages, and related settings. Both commands are now documented in your keybindings.json file for future reference.

---

_**User**_

and how about opening to the settings panel for these ones, as well? more one liners?

---

_**Assistant**_

Yes! Let me add the command to open the Keyboard settings panel where key repeat and press-and-hold settings are configured.

---

_****_

```diff
  
  // NOTES:
+ // open "x-apple.systempreferences:com.apple.Keyboard-Settings"                  // open Keyboard settings panel
  // defaults write -g ApplePressAndHoldEnabled -bool false                         // disable accept popup on press and hold
  // defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false // disable insert period on double space
```

---

_****_

I've added the command that will directly open the Keyboard settings panel. You can copy and run this command in your terminal:

```bash
open "x-apple.systempreferences:com.apple.Keyboard-Settings"
```

This will take you directly to the Keyboard settings panel in System Settings where you can configure:
- Key repeat rate
- Key repeat delay
- Press-and-hold behavior
- And other keyboard-related settings

Now you have quick CLI access to all three relevant settings panels:
1. General Keyboard settings (for key repeat)
2. Text Input settings (for auto-correction and smart features)
3. Language & Region settings (for input methods)

---

_**User**_

and how about yet more cli oneliners for these settings and how also can I list all the current settings (and is it possible to get a list of what the defaults are if anything has changed from the default?)

---

_**Assistant**_

I'll add commands to open the keyboard shortcuts panel and also add commands to read/check the current settings.

---

_****_

```diff
  // After changing settings:
  // killall SystemUIServer                                                        // restart UI to apply changes
+ 
+ // Open Keyboard Shortcuts Settings:
+ // open "x-apple.systempreferences:com.apple.Keyboard-Settings.shortcuts"        // open Keyboard Shortcuts panel
+ // open "x-apple.systempreferences:com.apple.Keyboard-Settings.modifier"         // open Modifier Keys panel
+ 
+ // Read current settings:
+ // defaults read -g ApplePressAndHoldEnabled                                     // check press-and-hold setting
+ // defaults read -g KeyRepeat                                                    // check key repeat rate
+ // defaults read -g InitialKeyRepeat                                            // check key repeat delay
+ // defaults read -g NSAutomaticSpellingCorrectionEnabled                        // check spelling correction
+ // defaults read -g NSAutomaticCapitalizationEnabled                            // check auto capitalization
+ // defaults read -g NSAutomaticTextCompletionEnabled                            // check predictive text
+ // defaults read -g NSAutomaticQuoteSubstitutionEnabled                         // check smart quotes
+ // defaults read -g NSAutomaticDashSubstitutionEnabled                          // check smart dashes
+ // defaults read NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled           // check double-space period
+ 
+ // List all defaults for an app/domain:
+ // defaults read com.apple.TextInputMenu                                        // read all TextInput settings
+ // defaults read -g                                                            // read all global settings
+ // defaults find KeyRepeat                                                     // find all domains containing a key
+ 
+ // Export/Backup current defaults:
+ // defaults domains | tr ',' '\n' | xargs -I{} sh -c 'echo "Domain: {}"; defaults read {}'  // list ALL defaults
+ // defaults export com.apple.TextInputMenu /tmp/text_input_defaults.plist      // export specific domain
+ // defaults export -g /tmp/global_defaults.plist                               // export global defaults
+ 
+ // Note: There's no direct way to see original default values if they've been changed.
+ // You can either:
+ // 1. Check on a fresh macOS installation
+ // 2. Create a new user account to see defaults
+ // 3. Reset all defaults: defaults delete domain-name
  
  
```

---

_****_

I've added several categories of useful commands:

1. Additional settings panel shortcuts:
```bash
open "x-apple.systempreferences:com.apple.Keyboard-Settings.shortcuts"  # Keyboard Shortcuts
open "x-apple.systempreferences:com.apple.Keyboard-Settings.modifier"   # Modifier Keys
```

2. Commands to check current values:
```bash
defaults read -g KeyRepeat  # Check current key repeat rate
defaults read -g InitialKeyRepeat  # Check current delay
# etc. for other settings
```

3. Commands to list all settings:
```bash
defaults read -g  # Read all global settings
defaults read com.apple.TextInputMenu  # Read all text input settings
defaults find KeyRepeat  # Find all domains containing a specific key
```

4. Commands to export/backup settings:
```bash
# Export all settings
defaults domains | tr ',' '\n' | xargs -I{} sh -c 'echo "Domain: {}"; defaults read {}'

# Export specific domains
defaults export com.apple.TextInputMenu /tmp/text_input_defaults.plist
defaults export -g /tmp/global_defaults.plist
```

Regarding your question about seeing default values: Unfortunately, there's no direct way to see the original default values once they've been changed. The options are:
1. Check on a fresh macOS installation
2. Create a new user account to see defaults
3. Reset defaults for a specific domain: `defaults delete domain-name`

You can also reset individual settings by deleting them:
```bash
defaults delete -g KeyRepeat  # Removes the custom setting, reverting to default
```

All these commands are now documented in your keybindings.json file for future reference.

---

_**User**_

when typing `Option-S` (Left Option key!) it inserts the `ß` character, but I don't want that, instead i want everywhere that I type the left option key to behave like iTerm2 `Esc+`, so how can I change that on a mac (and I want to maybe let the `Right Option` key to do the diacritic and funny character insert

---

_**Assistant**_

I'll help you configure this. You'll want to set the Left Option key to act as Esc+ while keeping the Right Option key for special characters. Let me add the relevant settings.

---

_****_

```diff
  // open "x-apple.systempreferences:com.apple.Keyboard-Settings.textinput"        // open Text Input settings panel
  // open "x-apple.systempreferences:com.apple.Language-Region-Settings"           // open Language & Region settings
+ 
+ // Option Key Settings:
+ // open "x-apple.systempreferences:com.apple.Keyboard-Settings.modifier"         // open Modifier Keys settings
+ // defaults write -g com.apple.keyboard.modifiermapping.1452-566-0 -array-add '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771113</integer></dict>'  // Set Left Option to Esc+
+ 
+ // Check current modifier mappings:
+ // hidutil property --get "UserKeyMapping"                                      // show current key mappings
+ // defaults -currentHost read -g com.apple.keyboard.modifiermapping            // read modifier key mappings
+ 
+ // Reset modifier mappings:
+ // defaults -currentHost delete -g com.apple.keyboard.modifiermapping          // reset all modifier mappings
  
  // defaults write com.apple.TextInputMenu visible -bool false                    // hide input menu from menu bar
```

---

_****_

There are two ways to achieve what you want:

1. **GUI Method (Easiest)**:
```bash
open "x-apple.systempreferences:com.apple.Keyboard-Settings.modifier"
```
This will open the Modifier Keys settings where you can:
1. Select your keyboard
2. Change "Option (⌥) Key" on the left side to "Esc+"
3. Leave the right Option key as "Option"

2. **Command Line Method**:
First, check your current keyboard identifier:
```bash
hidutil property --get "UserKeyMapping"
```

Then set the Left Option key to Esc+ while keeping Right Option as is:
```bash
defaults write -g com.apple.keyboard.modifiermapping.1452-566-0 -array-add '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771113</integer></dict>'
```

Note: The keyboard identifier (1452-566-0) might be different for your keyboard. You can find your keyboard's identifier by checking:
```bash
defaults -currentHost read -g com.apple.keyboard.modifiermapping
```

If you need to reset the settings:
```bash
defaults -currentHost delete -g com.apple.keyboard.modifiermapping
```

I recommend using the GUI method first since it's safer and easier to revert if needed. The command-line method requires precise keyboard identifiers and can vary between different keyboard models.

After making these changes, your:
- Left Option key will act as Esc+ (like in iTerm2)
- Right Option key will retain the normal Option behavior for typing special characters (ß, é, etc.)

You'll need to log out and back in for these changes to take full effect.

---



---

