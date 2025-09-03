#!/bin/bash

# Use provided folder or current directory
FOLDER=${1:-.}

echo "Fetching and pulling latest changes..."
echo "Folder: $FOLDER"
echo

cd "$FOLDER"
git fetch --all

# Check if main branch exists, otherwise use master
if git show-ref --verify --quiet refs/heads/main; then
    BRANCH="main"
elif git show-ref --verify --quiet refs/heads/master; then
    BRANCH="master"
else
    echo "Neither main nor master branch found!"
    exit 1
fi

echo "Switching to $BRANCH branch..."
git checkout $BRANCH

echo "Pulling latest changes from origin/$BRANCH..."
git pull origin $BRANCH

echo
echo "Done!"