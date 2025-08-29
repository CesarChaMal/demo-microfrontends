#!/bin/bash

# Use provided message or default to "Update"
MESSAGE=${1:-"Update"}
# Use provided folder or current directory
FOLDER=${2:-.}

echo "Committing and pushing changes..."
echo "Message: $MESSAGE"
echo "Folder: $FOLDER"
echo

cd "$FOLDER"
git add .
git commit -m "$MESSAGE"

git push

echo
echo "Done!"