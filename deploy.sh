#!/bin/bash

# Check for unstaged or uncommitted changes
if [[ $(git status --porcelain) ]]; then
    echo "You have unstaged or uncommitted changes. Please commit or stash your changes before deploying."
    exit 1
fi

# Save the current branch name
current_branch=$(git branch --show-current)

# Assumes you've already built a web export to ./build, with index.html as the entrypoint

# Create the gh-pages branch if it doesn't exist
git checkout --orphan gh-pages

# Remove all tracked files from Git's index, but leave the actual files in the working directory
git rm -rf --cached .

# Copy the contents of the /build directory to the root of the gh-pages branch
cp -r .build/* .

# Add all files and commit them
git add .
git commit -m "Deploy build to GitHub Pages"

# Push the changes to the gh-pages branch
git push -u origin gh-pages --force

# Switch back to the original branch
git checkout "$current_branch"
