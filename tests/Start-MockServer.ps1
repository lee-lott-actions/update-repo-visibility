param(
    [int]$Port = 3000
)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()

Write-Host "Mock server listening on http://127.0.0.1:$Port..." -ForegroundColor Green

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.LocalPath
        $method = $request.HttpMethod
        
        Write-Host "Mock intercepted: $method $path" -ForegroundColor Cyan

        $responseJson = $null
        $statusCode = 200

        # HealthCheck endpoint: GET /HealthCheck
        if ($method -eq "GET" -and $path -eq "/HealthCheck") {
            $statusCode = 200
            $responseJson = @{ status = "ok" } | ConvertTo-Json
        }
        # PATCH /repos/:owner/:repo
        elseif ($method -eq "PATCH" -and $path -match '^/repos/([^/]+)/([^/]+)$') {
            $owner = $Matches[1]
            $repo = $Matches[2]
            
            $headers = $request.Headers
            $reader = New-Object System.IO.StreamReader($request.InputStream)
            $requestBody = $reader.ReadToEnd()
            $reader.Close()
            Write-Host "Request headers: $($headers | Out-String)"
            Write-Host "Request body: $requestBody"

            $bodyObj = $null
            try { $bodyObj = $requestBody | ConvertFrom-Json } catch { $bodyObj = $null }
            $visibility = $bodyObj.visibility

            if ($null -eq $visibility -or ($visibility -notin @('public', 'private', 'internal'))) {
                $statusCode = 422
                $responseJson = @{ message = "Invalid visibility value. Must be public, private, or internal." } | ConvertTo-Json
            }
            else {
                $statusCode = 200
                $responseJson = @{ message = "Repository created" } | ConvertTo-Json
            }
        }
        else {
            $statusCode = 404
            $responseJson = @{ message = "Not Found" } | ConvertTo-Json
        }
        
        # Send response
        $response.StatusCode = $statusCode
        $response.ContentType = "application/json"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    }
}
finally {
    $listener.Stop()
    $listener.Close()
    Write-Host "Mock server stopped." -ForegroundColor Yellow
}
