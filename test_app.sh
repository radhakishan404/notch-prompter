#!/bin/bash

# Kill any running instances
pkill -9 NotchPrompter 2>/dev/null

# Wait a moment
sleep 1

# Launch the app normally
echo "Launching app via 'open' command..."
open /Applications/NotchPrompter.app

# Wait for app to start
sleep 2

# Check if it's running
if pgrep -x "NotchPrompter" > /dev/null; then
    echo "✅ App is running (PID: $(pgrep -x NotchPrompter))"
    
    # Check the log file
    LOG_FILE="$HOME/Documents/NotchPrompter.log"
    if [ -f "$LOG_FILE" ]; then
        echo ""
        echo "📋 Last 20 lines of log file:"
        tail -20 "$LOG_FILE"
    else
        echo "⚠️  Log file not found at $LOG_FILE"
    fi
    
    echo ""
    echo "Now try pressing ⌘⇧Space to test global shortcuts..."
    echo "Press Ctrl+C to stop monitoring"
    echo ""
    
    # Monitor the log file for new entries
    tail -f "$LOG_FILE" 2>/dev/null
else
    echo "❌ App failed to start"
fi
