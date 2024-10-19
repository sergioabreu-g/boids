#!/bin/bash

# Makes deploying to github pages easier
# Make sure everything is staged/committed to your current branch before running this file
# Export project as Web (Runnable), with Progressive Web App option enabled, saving to .build/, with
# with the file named index.html.
# This script will:
#  1. create/checkout a local branch called `gh-pages` based only on the current ./build folder
#  2. force push the branch to remote/gh-pages
#  3. switch back to your current branch

# All you gotta do is point your github pages configuration to the "gh-pages" branch, and github should
# automate everything else with each push. You can then access the project at
# https://{user_name}.github.io/{repo_name}/


# Check for unstaged or uncommitted changes
if [[ $(git status --porcelain) ]]; then
  echo "You have unstaged or uncommitted changes. Please commit or stash your changes before deploying."
  exit 1
fi

# Save the current branch name
current_branch=$(git branch --show-current)

# Assumes you've already built a web export to ./build, with index.html as the entrypoint

# Check if the gh-pages branch exists and delete it if it does
if git show-ref --verify --quiet refs/heads/gh-pages; then
  echo "Deleting existing gh-pages branch."
  git branch -D gh-pages
fi

# Create the gh-pages branch as an orphan
git checkout --orphan gh-pages || { echo "Failed to create gh-pages branch"; exit 1; }

# Remove all tracked files from Git's index, but leave the actual files in the working directory
git rm -rf --cached .

# # Copy the contents of the /build directory to the root of the gh-pages branch
cp -r .build/* .

# # Add all files and commit them
git add .
git commit -m "Deploy build to GitHub Pages"

# # Push the changes to the gh-pages branch
git push -u origin gh-pages --force

# # Switch back to the original branch
git checkout "$current_branch"
