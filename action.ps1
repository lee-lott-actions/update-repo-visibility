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

    if ($response.StatusCode -eq 200) {
      Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
      Write-Host "Successfully updated visibility of $Owner/$RepoName to $Visibility"
    }
    else {
      $errorMessage = ($response.Content | ConvertFrom-Json).message
      Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
      Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Failed to update visibility to $Visibility`: $errorMessage"
      Write-Host "Error: Failed to update visibility to $Visibility`: $errorMessage"
    }
  }
  catch {
    $errorMessage = "Unknown error"
    if ($_.Exception.Response) {
      $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $responseBody = $reader.ReadToEnd()
      $reader.Close()
      try {
        $errorMessage = ($responseBody | ConvertFrom-Json).message
      }
      catch {
        $errorMessage = $responseBody
      }
    }
    
    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Failed to update visibility to $Visibility`: $errorMessage"
    Write-Host "Error: Failed to update visibility to $Visibility`: $errorMessage"
  }
}
