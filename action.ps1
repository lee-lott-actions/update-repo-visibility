function Update-RepoVisibility {
  param(
    [string]$RepoName,
    [string]$Owner,
    [string]$Token,
    [string]$Visibility
  )

  # Validate required inputs
  if ([string]::IsNullOrEmpty($RepoName) -or [string]::IsNullOrEmpty($Visibility) -or [string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Token)) {
    Write-Host "Error: Missing required parameters"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
    return
  }

  # Validate visibility input
  if ($Visibility -notin @('public', 'private', 'internal')) {
    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Invalid visibility value: $Visibility. Must be public, private, or internal."
    Write-Host "Error: Invalid visibility value: $Visibility. Must be public, private, or internal."
    return
  }

  Write-Host "Updating visibility for repository: $Owner/$RepoName to $Visibility"

  # Use MOCK_API if set, otherwise default to GitHub API
  $apiBaseUrl = if ($env:MOCK_API) { $env:MOCK_API } else { "https://api.github.com" }
  $apiUrl = "$apiBaseUrl/repos/$Owner/$RepoName"

  try {
    $headers = @{
      "Authorization" = "Bearer $Token"
      "Accept"        = "application/vnd.github.v3+json"
      "Content-Type"  = "application/json"
    }

    $body = @{
      visibility = $Visibility
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri $apiUrl -Method Patch -Headers $headers -Body $body -ErrorAction Stop

    Write-Host "Update Visibility API Response Code: $($response.StatusCode)"
    Write-Host $response.Content

    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
    Write-Host "Successfully updated visibility of $Owner/$RepoName to $Visibility"
  }
  catch {
    $errorMessage = "Unknown error"
    
    if ($_.ErrorDetails.Message) {
      try {
        $errorMessage = ($_.ErrorDetails.Message | ConvertFrom-Json).message
      }
      catch {
        $errorMessage = $_.ErrorDetails.Message
      }
    }
    elseif ($_.Exception.Message) {
      $errorMessage = $_.Exception.Message
    }
    
    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Failed to update visibility to $Visibility`: $errorMessage"
    Write-Host "Error: Failed to update visibility to $Visibility`: $errorMessage"
  }
}
