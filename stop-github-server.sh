#!/bin/bash

# Stop GitHub repository creation server
echo "🛑 Stopping GitHub repository creation server..."

# Find and kill the GitHub server process
GITHUB_PID=$(ps aux | grep "github-repo-server.js" | grep -v grep | awk '{print $2}')

if [ -n "$GITHUB_PID" ]; then
    echo "🔍 Found GitHub server process: $GITHUB_PID"
    kill $GITHUB_PID
    echo "✅ GitHub server stopped"
else
    echo "ℹ️  No GitHub server process found"
fi

# Also kill any Node.js processes on port 3001
PORT_PID=$(lsof -ti:3001 2>/dev/null)
if [ -n "$PORT_PID" ]; then
    echo "🔍 Found process on port 3001: $PORT_PID"
    kill $PORT_PID
    echo "✅ Process on port 3001 stopped"
fi

echo "🏁 GitHub server cleanup complete"