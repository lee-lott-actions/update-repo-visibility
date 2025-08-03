
#!/usr/bin/env bats

# Load the Bash script
load ../action.sh

# Mock the curl command to simulate API responses
mock_curl() {
  local http_code=$1
  local response_file=$2
  echo "$http_code"
  cat "$response_file" > visibility_response.json
}

# Setup function to run before each test
setup() {
  export GITHUB_OUTPUT=$(mktemp)
}

# Teardown function to clean up after each test
teardown() {
  rm -f visibility_response.json "$GITHUB_OUTPUT" mock_response.json
}

@test "update_visibility succeeds with public visibility and HTTP 200" {
  echo '{"message": "Repository updated"}' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }
  export -f curl

  run update_visibility "existing-repo" "test-owner" "fake-token" "public"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
}

@test "update_visibility succeeds with private visibility and HTTP 200" {
  echo '{"message": "Repository updated"}' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }
  export -f curl

  run update_visibility "existing-repo" "test-owner" "fake-token" "private"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
}

@test "update_visibility succeeds with internal visibility and HTTP 200" {
  echo '{"message": "Repository updated"}' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }
  export -f curl

  run update_visibility "existing-repo" "test-owner" "fake-token" "internal"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
}

@test "update_visibility fails with HTTP 404" {
  echo '{"message": "Not Found"}' > mock_response.json
  curl() { mock_curl "404" mock_response.json; }
  export -f curl

  run update_visibility "non-existing-repo" "test-owner" "fake-token" "public"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Failed to update visibility to public: Not Found" ]
}

@test "update_visibility fails with HTTP 500" {
  echo '{"message": "Server Error"}' > mock_response.json
  curl() { mock_curl "500" mock_response.json; }
  export -f curl

  run update_visibility "invalid-repo" "test-owner" "fake-token" "public"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Failed to update visibility to public: Server Error" ]
}

@test "update_visibility fails with invalid visibility" {
  run update_visibility "existing-repo" "test-owner" "fake-token" "invalid"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Invalid visibility value: invalid. Must be public, private, or internal." ]
}

@test "update_visibility fails with empty repo_name" {
  run update_visibility "" "test-owner" "fake-token" "public"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided." ]
}

@test "update_visibility fails with empty owner" {
  run update_visibility "existing-repo" "" "fake-token" "public"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided." ]
}

@test "update_visibility fails with empty token" {
  run update_visibility "existing-repo" "test-owner" "" "public"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided." ]
}

@test "update_visibility fails with empty visibility" {
  run update_visibility "existing-repo" "test-owner" "fake-token" ""

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided." ]
}
