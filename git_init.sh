#!/bin/bash

# Prompt for repository name (folder name)
read -p "Enter the repository name (folder name): " folder_name

# Check if .gitignore exists in the folder
if [ ! -f "$folder_name/.gitignore" ]; then
  echo ".gitignore file not found in $folder_name. Creating and populating .gitignore file..."
  cat <<EOL > "$folder_name/.gitignore"
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/
EOL
fi

# Navigate to the folder
cd "$folder_name" || exit

# Prompt for branch name
read -p "Enter the branch name: " branch_name

# Prompt for commit message
read -p "Enter the commit message: " commit_message

# Authenticate with GitHub and create a private repository if it doesn't exist
echo "Authenticating with GitHub..."
response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $GIT_PAT_KEY" https://api.github.com/repos/$GIT_USERNAME/$folder_name)

if [ "$response" -eq 404 ]; then
  echo "Repository does not exist. Creating a new private repository..."
  curl -H "Authorization: Bearer $GIT_PAT_KEY" https://api.github.com/user/repos -d "{\"name\":\"$folder_name\",\"private\":true}"
else
  echo "Repository already exists. Checking if remote origin is set..."
  if git remote | grep -q "origin"; then
    echo "Pulling the latest changes from origin..."
    git pull origin main
  else
    echo "Remote origin not set. Skipping pull step."
  fi
fi

# Initialize a new Git repository if it doesn't exist
if [ ! -d ".git" ]; then
  git init
fi

# Check if remote origin exists before removing it
if git remote | grep -q "origin"; then
  git remote remove origin
fi

# Show the status before adding files
echo "Status before adding files:"
git status

# Add only modified files to the repository one by one
echo "Adding modified files one by one:"
for file in $(git status -s | awk '{print $2}'); do
  echo "Adding $file"
  git add "$file"
done

# Show the status after adding files
echo "Status after adding files:"
git status

# Commit the files with the user-provided message
git commit -m "$commit_message"

# Add the new remote repository using PAT for authentication
git remote add origin https://$GIT_USERNAME:$GIT_PAT_KEY@github.com/$GIT_USERNAME/$folder_name.git

# Create the specified branch
git checkout -b "$branch_name"

# Push the files to the specified branch
git push -u origin "$branch_name"

echo "Repository '$folder_name' created and files pushed to branch '$branch_name' on GitHub!"
