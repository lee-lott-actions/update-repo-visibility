BeforeAll {
  # Load the PowerShell script
  . "$PSScriptRoot/../action.ps1"
}

Describe "Update-RepoVisibility" {
  BeforeEach {
    # Setup function to run before each test
    $env:GITHUB_OUTPUT = [System.IO.Path]::GetTempFileName()
  }

  AfterEach {
    # Teardown function to clean up after each test
    if (Test-Path $env:GITHUB_OUTPUT) {
      Remove-Item $env:GITHUB_OUTPUT -Force
    }
  }

  It "succeeds with public visibility and HTTP 200" {
    # Mock Invoke-WebRequest
    Mock Invoke-WebRequest {
      return @{
        StatusCode = 200
        Content    = '{"message": "Repository visibility updated"}'
      }
    }

    Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "fake-token" -Visibility "public"

    $output = Get-Content $env:GITHUB_OUTPUT
    $output | Should -Contain "result=success"
  }

  It "succeeds with private visibility and HTTP 200" {
    Mock Invoke-WebRequest {
      return @{
        StatusCode = 200
        Content    = '{"message": "Repository visibility updated"}'
      }
    }

    Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "fake-token" -Visibility "private"

    $output = Get-Content $env:GITHUB_OUTPUT
    $output | Should -Contain "result=success"
  }

  It "succeeds with internal visibility and HTTP 200" {
    Mock Invoke-WebRequest {
      return @{
        StatusCode = 200
        Content    = '{"message": "Repository visibility updated"}'
      }
    }

    Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "fake-token" -Visibility "internal"

    $output = Get-Content $env:GITHUB_OUTPUT
    $output | Should -Contain "result=success"
  }

  It "fails with HTTP 404" {
    Mock Invoke-WebRequest {
      $errorRecord = [System.Management.Automation.ErrorRecord]::new(
        [System.Exception]::new("404 Not Found"),
        "WebCmdletWebResponseException",
        [System.Management.Automation.ErrorCategory]::InvalidOperation,
        $null
      )
      $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new('{"message": "Not Found"}')
      throw $errorRecord
    }

    Update-RepoVisibility -RepoName "non-existing-repo" -Owner "test-owner" -Token "fake-token" -Visibility "public"

    $output = Get-Content $env:GITHUB_OUTPUT -Raw
    $output | Should -Match "result=failure"
    $output | Should -Match "error-message=Failed to update visibility to public"
  }

  It "fails with invalid visibility" {
    Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "fake-token" -Visibility "invalid"

    $output = Get-Content $env:GITHUB_OUTPUT
    $output | Should -Contain "result=failure"
    $output | Should -Contain "error-message=Invalid visibility value: invalid. Must be public, private, or internal."
  }

  It "fails with empty repo_name" {
    Update-RepoVisibility -RepoName "" -Owner "test-owner" -Token "fake-token" -Visibility "public"

    $output = Get-Content $env:GITHUB_OUTPUT
    $output | Should -Contain "result=failure"
    $output | Should -Contain "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
  }

  It "fails with empty owner" {
    Update-RepoVisibility -RepoName "existing-repo" -Owner "" -Token "fake-token" -Visibility "public"

    $output = Get-Content $env:GITHUB_OUTPUT
    $output | Should -Contain "result=failure"
    $output | Should -Contain "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
  }

  It "fails with empty token" {
    Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "" -Visibility "public"

    $output = Get-Content $env:GITHUB_OUTPUT
    $output | Should -Contain "result=failure"
    $output | Should -Contain "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
  }

  It "fails with empty visibility" {
    Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "fake-token" -Visibility ""

    $output = Get-Content $env:GITHUB_OUTPUT
    $output | Should -Contain "result=failure"
    $output | Should -Contain "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
  }
}
