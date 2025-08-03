# Update Repository Visibility Action

This GitHub Action updates the visibility of a specified repository to `public`, `private`, or `internal` using the GitHub API. It returns a result indicating success or failure and an error message if the operation fails.

## Features
- Updates a repository's visibility to `public`, `private`, or `internal` via the GitHub API.
- Outputs a result (`success` or `failure`) and an error message for easy integration into workflows.
- Requires a GitHub token with `repo` scope for repository updates.

## Inputs
| Name         | Description                                      | Required | Default   |
|--------------|--------------------------------------------------|----------|-----------|
| `repo-name`  | The name of the repository to update.            | Yes      | N/A       |
| `owner`      | The owner of the repository (user or organization). | Yes      | N/A       |
| `token`      | GitHub token with repository write access.       | Yes      | N/A       |
| `visibility` | The visibility to set for the repository (public, private, or internal). | Yes      | private   |

## Outputs
| Name           | Description                                           |
|----------------|-------------------------------------------------------|
| `result`       | Result of the visibility update (`success` for HTTP 200, `failure` otherwise). |
| `error-message`| Error message if the visibility update fails.         |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/update-repo-visibility.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`), or the local path if stored in the same repository.

3. **Example Workflow**:
   ```yaml
   name: Update Repository Visibility
   on:
     push:
       branches:
         - main
   jobs:
     update-visibility:
       runs-on: ubuntu-latest
       steps:
         - name: Update Repository Visibility
           id: update
           uses: la-actions/update-repo-visibility@v1.0.0
           with:
             repo-name: 'my-repo'
             owner: ${{ github.repository_owner }}
             token: ${{ secrets.GITHUB_TOKEN }}
             visibility: 'internal'
         - name: Check Result
           run: |
             if [[ "${{ steps.update.outputs.result }}" == "success" ]]; then
               echo "Repository visibility updated successfully."
             else
               echo "${{ steps.update.outputs.error-message }}"
               exit 1
             fi
