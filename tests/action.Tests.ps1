Describe "Update-RepoVisibility" {
	BeforeAll {
		$script:RepoName = "existing-repo"
		$script:Owner = "test-owner"
		$script:Token = "fake-token"
		$script:Visibility = "public"  
		. "$PSScriptRoot/../action.ps1"
	}

	BeforeEach {
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl
    }
	
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

	Context "Success Cases" {
		It "unit: Update-RepoVisibility succeeds with public visibility and HTTP 200" {
			Mock Invoke-WebRequest {
			  return @{
				StatusCode = 200
				Content    = '{"message": "Repository visibility updated"}'
			  }
			}
	
			Update-RepoVisibility -RepoName $RepoName -Owner $Owner -Token $Token -Visibility "public"
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=success"
		}

		It "unit: Update-RepoVisibility succeeds with private visibility and HTTP 200" {
			Mock Invoke-WebRequest {
				[PSCustomObject]@{ StatusCode = 200; Content = '{"message": "Repository visibility updated"}' }
			}
	
			Update-RepoVisibility -RepoName $RepoName -Owner $Owner -Token $Token -Visibility "private"
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=success"
		}
	
		It "unit: Update-RepoVisibility succeeds with internal visibility and HTTP 200" {
			Mock Invoke-WebRequest {
				[PSCustomObject]@{ StatusCode = 200; Content = '{"message": "Repository visibility updated"}' }
			}
	
			Update-RepoVisibility -RepoName $RepoName -Owner $Owner -Token $Token -Visibility "internal"
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=success"
		}		
	}

	Context "HTTP Failure Cases" {
		It "unit: Update-RepoVisibility fails with HTTP 404" {
			Mock Invoke-WebRequest {
				[PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Not Found"}' }
			}
	
			Update-RepoVisibility -RepoName $RepoName -Owner $Owner -Token $Token -Visibility $Visibility
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Where-Object { $_ -match "^error-message=Error: Failed to update visibility of $Owner/$RepoName to $Visibility\. HTTP Status:" } |
				Should -Not -BeNullOrEmpty
		}	
	}

	Context "Parameter Validation Failure Cases" {
		It "unit: Update-RepoVisibility fails with empty RepoName" {
			Update-RepoVisibility -RepoName "" -Owner "test-owner" -Token "fake-token" -Visibility "public"
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Should -Contain "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
		}
	
		It "unit: Update-RepoVisibility fails with empty Owner" {
			Update-RepoVisibility -RepoName "existing-repo" -Owner "" -Token "fake-token" -Visibility "public"
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Should -Contain "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
		}
	
		It "unit: Update-RepoVisibility fails with empty Token" {
			Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "" -Visibility "public"
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Should -Contain "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
		}
	
		It "unit: Update-RepoVisibility fails with empty Visibility" {
			Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "fake-token" -Visibility ""
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Should -Contain "error-message=Missing required parameters: repo_name, visibility, owner, and token must be provided."
		}	

		It "unit: Update-RepoVisibility fails with invalid Visibility" {
			Update-RepoVisibility -RepoName "existing-repo" -Owner "test-owner" -Token "fake-token" -Visibility "invalid"
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Should -Contain "error-message=Invalid visibility value: invalid. Must be public, private, or internal."
		}
	}

	Context "Exception Failure Cases" {
		It "unit: Update-RepoVisibility fails with exception" {
			Mock Invoke-WebRequest { throw "API Error" }
	
			try {
				Update-RepoVisibility -RepoName $RepoName -Owner $Owner -Token $Token -Visibility $Visibility
			} catch {}
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Where-Object { $_ -match "^error-message=Error: Failed to update visibility of $Owner/$RepoName to $Visibility\. Exception:" } |
				Should -Not -BeNullOrEmpty
		}  
	}
}
