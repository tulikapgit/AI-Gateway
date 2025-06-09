# PowerShell script to verify API versions in Bicep files
# This script checks if API versions in APIM-related Bicep files have been updated correctly

Write-Host "Verifying API versions in Bicep files..." -ForegroundColor Cyan

# Path to the main module we need to check
$openaiApiPath = "..\..\modules\apim\v1\openai-api.bicep"

# Verify file exists
if (-not (Test-Path $openaiApiPath)) {
    Write-Host "Error: Could not find the openai-api.bicep file at $openaiApiPath" -ForegroundColor Red
    exit 1
}

# Read the file content
$content = Get-Content $openaiApiPath -Raw

# Check API versions
$issues = @()

# Check for problematic API versions
if ($content -match "Microsoft.ApiManagement/service@2023-05-01") {
    $issues += "Found Microsoft.ApiManagement/service@2023-05-01 which may cause issues"
}

if ($content -match "Microsoft.ApiManagement/service@2024-05-01") {
    $issues += "Found Microsoft.ApiManagement/service@2024-05-01 which may cause issues"
}

if ($content -match "Microsoft.ApiManagement/service/apis@2023-05-01") {
    $issues += "Found Microsoft.ApiManagement/service/apis@2023-05-01 which may cause issues"
}

if ($content -match "Microsoft.ApiManagement/service/apis@2024-05-01") {
    $issues += "Found Microsoft.ApiManagement/service/apis@2024-05-01 which may cause issues"
}

if ($content -match "Microsoft.ApiManagement/service/backends@2022-08-01" -and $content -match "circuitBreaker") {
    $issues += "Found Microsoft.ApiManagement/service/backends@2022-08-01 with circuit breaker functionality which will cause issues"
}

# Check for required API versions
$requiredVersions = @(
    @{Name="Backend Pool API Version"; Pattern="Microsoft.ApiManagement/service/backends@2021-12-01-preview"; Required=$true},
    @{Name="Circuit Breaker API Version"; Pattern="Microsoft.ApiManagement/service/backends@2022-09-01-preview"; Required=$true}
)

foreach ($version in $requiredVersions) {
    if ($version.Required -and -not ($content -match $version.Pattern)) {
        $issues += "Missing required $($version.Name): $($version.Pattern)"
    }
}

# Report findings
if ($issues.Count -eq 0) {
    Write-Host "All API versions look good! The deployment should work properly." -ForegroundColor Green
} else {
    Write-Host "Found $($issues.Count) potential issues:" -ForegroundColor Yellow
    foreach ($issue in $issues) {
        Write-Host " - $issue" -ForegroundColor Yellow
    }
    Write-Host "Please run the update-api-versions.ps1 script to fix these issues." -ForegroundColor Yellow
}

# Check apim.bicep file too
$apimPath = "..\..\modules\apim\v1\apim.bicep"
if (Test-Path $apimPath) {
    Write-Host "`nChecking $apimPath..." -ForegroundColor Cyan
    $content = Get-Content $apimPath -Raw
    
    $apimIssues = @()
    
    if ($content -match "Microsoft.ApiManagement/service@2023-05-01") {
        $apimIssues += "Found Microsoft.ApiManagement/service@2023-05-01 which may cause issues"
    }
    
    if ($content -match "Microsoft.ApiManagement/service@2024-05-01") {
        $apimIssues += "Found Microsoft.ApiManagement/service@2024-05-01 which may cause issues"
    }
    
    if ($apimIssues.Count -eq 0) {
        Write-Host "All API versions in apim.bicep look good!" -ForegroundColor Green
    } else {
        Write-Host "Found $($apimIssues.Count) potential issues in apim.bicep:" -ForegroundColor Yellow
        foreach ($issue in $apimIssues) {
            Write-Host " - $issue" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nVerification complete." -ForegroundColor Cyan
