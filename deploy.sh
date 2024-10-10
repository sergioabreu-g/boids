#!/bin/bash
# Ensure you're on the correct branch (main or whichever you use for development)
git checkout main

# Build your project (optional step if needed before deploying)
# e.g., for Godot builds you already have in `/build`

# Create the gh-pages branch if it doesn't exist
git checkout --orphan gh-pages

# Remove all files from the index
git rm -rf .

# Copy the contents of the /build directory to the root
cp -r .build/* .

# Add all files and commit them
git add .
git commit -m "Deploy build to GitHub Pages"

# Push the changes to the gh-pages branch
git push -u origin gh-pages --force

# Go back to the main branch
git checkout main
