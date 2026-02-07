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

  # Normalize to lowercase for API compatibility
  $Visibility = $Visibility.ToLower()

  # Validate visibility value
  if ($Visibility -ne "public" -and $Visibility -ne "private" -and $Visibility -ne "internal") {
      Write-Output "Error: Invalid visibility value: $Visibility. Must be public, private, or internal."
      Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Invalid visibility value: $Visibility. Must be public, private, or internal."
      Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
      return
  }

  Write-Host "Updating visibility for repository: $Owner/$RepoName to $Visibility"

  # Use MOCK_API if set, otherwise default to GitHub API
  $apiBaseUrl = $env:MOCK_API
  if (-not $apiBaseUrl) { $apiBaseUrl = "https://api.github.com" }
  $uri = "$apiBaseUrl/repos/$Owner/$RepoName"

  $headers = @{
      Authorization          = "Bearer $Token"
      Accept                 = "application/vnd.github.v3+json"
      "User-Agent"           = "pwsh-action"
      "Content-Type"         = "application/json"
      "X-GitHub-Api-Version" = "2022-11-28"
  }

  $body = @{ visibility = $Visibility } | ConvertTo-Json

  try {
    $response = Invoke-WebRequest -Uri $uri -Method Patch -Headers $headers -Body $body

    if ($response.StatusCode -eq 200) {
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
		Write-Host "Successfully updated visibility of $Owner/$RepoName to $Visibility"  
    }
	else {
		Write-Host "Error: Failed to update visibility to $Visibility. HTTP Status: $($response.StatusCode)"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Failed to update visibility to $Visibility. HTTP Status: $($response.StatusCode)"      
	}    
  }
  catch {
	$errorMsg = "Error: Failed to update visibility of $Owner/$RepoName to $Visibility. Exception: $($_.Exception.Message)"
	Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"    
	Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
    Write-Host $errorMsg
  }
}
