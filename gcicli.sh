#!/bin/bash

# Prompt for the full path of the repository
read -p "Enter the full path of the repository: " full_path

# Extract the folder name from the full path
folder_name=$(basename "$full_path")

# Check if .gitignore_template exists in the current directory
if [ ! -f ".gitignore_template" ]; then
  echo ".gitignore_template file not found in the current directory. Please create a .gitignore_template file and try again."
  exit 1
fi

# Create .gitignore from .gitignore_template
cp ".gitignore_template" "$full_path/.gitignore"

# Navigate to the folder
cd "$full_path" || exit

# Read .gitignore patterns
ignore_patterns=$(cat .gitignore | grep -v '^#' | grep -v '^$')

# List folders and their sizes, excluding those in .gitignore
echo "Folders and their sizes:"
folders=()
sizes=()
for folder in */; do
  skip=false
  for pattern in $ignore_patterns; do
    if [[ $folder == $pattern* ]]; then
      skip=true
      break
    fi
  done
  if [ "$skip" = false ]; then
    folders+=("$folder")
    sizes+=($(du -sh "$folder" | awk '{print $1}'))
  fi
done

for i in "${!folders[@]}"; do
  echo "$i) ${folders[$i]} - ${sizes[$i]}"
done

# Prompt for folders to skip
read -p "Enter the numbers of folders to skip (comma-separated): " skip_numbers

# Convert the comma-separated list to an array
IFS=',' read -r -a skip_indices <<< "$skip_numbers"
skip_folders=()
for index in "${skip_indices[@]}"; do
  skip_folders+=("${folders[$index]}")
done

# Prompt for branch name
read -p "Enter the branch name: " branch_name

# Prompt for commit message
read -p "Enter the commit message: " commit_message

# Check if the repository is already initialized
if [ ! -d ".git" ]; then
  # Initialize a new Git repository if it doesn't exist
  git init
else
  # Pull the latest changes from the remote repository
  echo "Repository already exists. Pulling the latest changes from origin..."
  git pull origin main
fi

# Check if remote origin exists before removing it
if git remote | grep -q "origin"; then
  git remote remove origin
fi

# Show the status before adding files
echo "Status before adding files:"
git status

# Add only modified files to the repository one by one, skipping specified folders
echo "Adding modified files one by one:"
for file in $(git status -s | awk '{print $2}'); do
  skip=false
  for folder in "${skip_folders[@]}"; do
    if [[ $file == $folder* ]]; then
      skip=true
      break
    fi
  done
  if [ "$skip" = false ]; then
    # Check if the file size is greater than 100 MB
    if [ $(stat -c%s "$file") -gt 104857600 ]; then
      read -p "$file is larger than 100 MB. Do you want to use Git LFS to track this file? (y/n): " use_lfs
      if [ "$use_lfs" = "y" ]; then
        git lfs track "$file"
        git add .gitattributes
      fi
    fi
    echo "Adding $file"
    git add "$file"
  else
    echo "Skipping $file"
  fi
done

# Show the status after adding files
echo "Status after adding files:"
git status

# Commit the files with the user-provided message
git commit -m "$commit_message"

# Add the new remote repository using PAT for authentication
git remote add origin https://$GIT_USERNAME:$GIT_PAT_KEY@github.com/$GIT_USERNAME/$folder_name.git

# Handle branch logic
if [ "$branch_name" = "main" ]; then
  git branch -M main
  git push -u origin main
else
  git checkout -b "$branch_name"
  git push -u origin "$branch_name"
fi

echo "Repository '$folder_name' created and files pushed to branch '$branch_name' on GitHub!"

