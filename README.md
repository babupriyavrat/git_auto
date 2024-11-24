Here's the complete `README.md` file with all the instructions and details:

```markdown
# Repository Initialization Script

This script automates the process of initializing a Git repository, creating a `.gitignore` file from a template, adding files to the repository, and pushing them to a remote GitHub repository. It also handles large files using Git LFS and allows users to skip specific folders during the `git add` process.

## Functionalities

1. **Initialize Git Repository**: Initializes a new Git repository if it doesn't already exist.
2. **Create `.gitignore` File**: Creates a `.gitignore` file from a `.gitignore_template` file located in the current directory.
3. **Skip Specified Folders**: Allows users to skip specific folders during the `git add` process.
4. **Handle Large Files**: Checks for files larger than 100 MB and prompts the user to use Git LFS to track them.
5. **Branch Management**: Handles branch creation and switching based on user input.
6. **Push to Remote Repository**: Pushes the committed files to a remote GitHub repository.

## Scenarios

1. **New Repository**: The script creates a new private repository on GitHub if it doesn't already exist.
2. **Existing Repository**: The script pulls the latest changes from the remote repository if it already exists.
3. **Large Files**: The script prompts the user to use Git LFS for files larger than 100 MB.
4. **Skipping Folders**: The script allows users to skip specific folders during the `git add` process.

## Installation Instructions

1. **Clone the Repository**: Clone the repository containing the script to your local machine.
   ```bash
   git clone https://github.com/yourusername/yourrepository.git
   ```

2. **Navigate to the Script Directory**: Change to the directory containing the script.
   ```bash
   cd yourrepository
   ```

3. **Ensure `.gitignore_template` Exists**: Make sure there is a `.gitignore_template` file in the current directory. This file should contain the patterns for files and folders to be ignored by Git.

4. **Run the Script**: Execute the script.
   ```bash
   ./git_init.sh  # for simple features (1,2 and 6)
   ./git_comprehensive_init.sh # for all features
   ```

## Usage Instructions

1. **Enter the Full Path of the Repository**: When prompted, enter the full path of the repository you want to initialize.
   ```bash
   Enter the full path of the repository: /path/to/your/repository
   ```

2. **Select Folders to Skip**: The script will list the folders and their sizes. Enter the numbers of the folders you want to skip, separated by commas.
   ```bash
   Enter the numbers of folders to skip (comma-separated): 0,2,4
   ```

3. **Enter Branch Name**: Enter the name of the branch you want to create or switch to.
   ```bash
   Enter the branch name: main
   ```

4. **Enter Commit Message**: Enter the commit message for the changes.
   ```bash
   Enter the commit message: "Initial commit"
   ```

5. **Handle Large Files**: If the script encounters a file larger than 100 MB, it will prompt you to use Git LFS to track the file.
   ```bash
   /path/to/large/file is larger than 100 MB. Do you want to use Git LFS to track this file? (y/n): y
   ```

6. **Push to Remote Repository**: The script will push the committed files to the remote GitHub repository.

## Requirements

- Git
- Git LFS (for handling large files)

## Notes

- Ensure you have the necessary permissions to create repositories on GitHub.
- Make sure your GitHub personal access token (PAT) has the required scopes (e.g., `repo`) to create and push to repositories.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

Feel free to customize the `README.md` file as needed. Let me know if you need any further assistance!
