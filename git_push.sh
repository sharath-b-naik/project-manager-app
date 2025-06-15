#!/bin/bash

# Ask for commit message
read -p "Enter commit message: " commit_msg

# Add all changes
git add .

# Commit with entered message
git commit -m "$commit_msg"

# Push to the current branch
git push

# Ask for a tag name (optional)
read -p "Enter tag name (leave blank to skip): " tag_name

# If tag is provided, create and push it
if [ ! -z "$tag_name" ]; then
  git tag "$tag_name"
  git push origin "$tag_name"
  echo "Tag '$tag_name' created and pushed."
else
  echo "No tag created."
fi
