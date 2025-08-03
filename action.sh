 #!/bin/bash

update_visibility() {
  local repo_name="$1"
  local owner="$2"
  local token="$3"
  local visibility="$4"

  # Validate required inputs
  if [ -z "$repo_name" ] || [ -z "$visibility" ] || [ -z "$owner" ] || [ -z "$token" ]; then
    echo "Error: Missing required parameters"
    echo "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided." >> "$GITHUB_OUTPUT"                        
    echo "result=failure" >> "$GITHUB_OUTPUT"
    return
  fi
  
  # Validate visibility input
  case "$visibility" in
    public|private|internal)
      ;;
    *)
      echo "result=failure" >> $GITHUB_OUTPUT
      echo "error-message=Invalid visibility value: $visibility. Must be public, private, or internal." >> $GITHUB_OUTPUT
      echo "Error: Invalid visibility value: $visibility. Must be public, private, or internal."
      return
      ;;
  esac
  
  echo "Updating visibility for repository: $owner/$repo_name to $visibility"
  # Use MOCK_API if set, otherwise default to GitHub API
  local api_base_url="${MOCK_API:-https://api.github.com}"
  local api_url="$api_base_url/repos/$owner/$repo_name"
  
  RESPONSE=$(curl -s -o visibility_response.json -w "%{http_code}" \
    -X PATCH \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Content-Type: application/json" \
    "$api_url" \
    -d "{\"visibility\": \"$visibility\"}")
    
  echo "Update Visibility API Response Code: $RESPONSE"  
  cat visibility_response.json
  
  if [ "$RESPONSE" -ne 200 ]; then
    echo "result=failure" >> $GITHUB_OUTPUT
    echo "error-message=Failed to update visibility to $visibility: $(jq -r .message visibility_response.json)" >> $GITHUB_OUTPUT
    echo "Error: Failed to update visibility to $visibility: $(jq -r .message visibility_response.json)"
    rm -f visibility_response.json
    return
  fi
  
  echo "result=success" >> $GITHUB_OUTPUT
  echo "Successfully updated visibility of $owner/$repo_name to $visibility"
  rm -f visibility_response.json
}
