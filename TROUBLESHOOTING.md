# NotchPrompter - Troubleshooting Guide

## Issue: Settings Menu Not Opening & Global Shortcuts Not Working

### Root Cause
The app is showing that accessibility permission is **FALSE** even though you've enabled it in System Settings. This is a macOS security feature - **accessibility permissions only take effect after the app is completely restarted**.

### Solution

**You MUST completely quit and restart the app after granting accessibility permission:**

1. **Quit the app completely:**
   - Right-click the menu bar icon and select "Quit"
   - OR press `Cmd+Q` when the app is focused
   - OR run this command: `pkill -9 NotchPrompter`

2. **Verify the app is fully closed:**
   - Check Activity Monitor to ensure no NotchPrompter processes are running
   - The menu bar icon should disappear

3. **Restart the app:**
   - Open from Applications folder
   - OR run: `open /Applications/NotchPrompter.app`

4. **Test the shortcuts:**
   - Try pressing `⌘⇧Space` while in VS Code or another app
   - The prompter should start/stop playing

### Debug Information

From the console output, we can see:
```
🎹 Registering global shortcuts...
🔐 Accessibility permission status: false  ← THIS IS THE PROBLEM
✅ Shortcuts registered. Global monitor: true, Local monitor: true
```

Even though the shortcuts are registered, they won't work globally without accessibility permission.

### Settings Window Issue

The settings window should now work with the fallback implementation. If it still doesn't open:
1. Check the console output when clicking Settings
2. Look for: `🔧 showSettingsWindow called`
3. The app will create a manual settings window if the standard approach fails

### Global Keyboard Shortcuts

Once accessibility permission is properly recognized (after restart), these shortcuts will work everywhere:

- `⌘⇧Space` - Play/Pause
- `⌘⇧E` - Open Editor
- `⌘⇧R` - Reset
- `⌘⇧]` - Speed up
- `⌘⇧[` - Slow down
- `⌘⇧=` - Font size up
- `⌘⇧-` - Font size down

### Verification Steps

After restarting, run the app from terminal to see debug output:
```bash
/Applications/NotchPrompter.app/Contents/MacOS/NotchPrompter
```

You should see:
```
🎹 Registering global shortcuts...
🔐 Accessibility permission status: true  ← Should be TRUE now
✅ Shortcuts registered. Global monitor: true, Local monitor: true
```

### If Still Not Working

1. Remove the app from Accessibility list in System Settings
2. Re-add it manually
3. Restart the app
4. Grant permission when prompted
5. Restart the app again
