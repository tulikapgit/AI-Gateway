# API Version Diagnostic Tool for Azure Gateway Labs

This PowerShell script helps diagnose API version issues in any of the Azure Gateway labs.
It searches all Bicep files in a specified lab directory and reports potential compatibility problems.

## Usage

```powershell
# Run from any lab directory
.\diagnose-api-versions.ps1 -LabPath "path\to\lab"
```

param (
    [Parameter(Mandatory=$false)]
    [string]$LabPath = "."
)

$ErrorActionPreference = "Stop"

Write-Host "API Version Diagnostic Tool for Azure Gateway Labs" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Check if path exists
if (-not (Test-Path $LabPath)) {
    Write-Host "Error: Path '$LabPath' does not exist." -ForegroundColor Red
    exit 1
}

# Get the absolute path
$LabPath = Resolve-Path $LabPath

Write-Host "Analyzing Bicep files in: $LabPath" -ForegroundColor Cyan

# Find all Bicep files in the lab directory and subdirectories
$bicepFiles = Get-ChildItem -Path $LabPath -Filter "*.bicep" -Recurse -File

if ($bicepFiles.Count -eq 0) {
    Write-Host "No Bicep files found in $LabPath" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($bicepFiles.Count) Bicep files to analyze." -ForegroundColor Green

# Define problematic API versions and their alternatives
$apiVersionChecks = @(
    @{
        Name = "Microsoft.ApiManagement/service";
        ProblematicVersions = @("2023-05-01", "2024-05-01");
        RecommendedVersion = "2021-12-01-preview";
        Risk = "High - May not be available in all regions"
    },
    @{
        Name = "Microsoft.ApiManagement/service/apis";
        ProblematicVersions = @("2023-05-01", "2024-05-01");
        RecommendedVersion = "2021-12-01-preview";
        Risk = "High - May not be available in all regions"
    },
    @{
        Name = "Microsoft.ApiManagement/service/backends";
        ProblematicVersions = @("2022-08-01");
        ContextPattern = "circuitBreaker";
        RecommendedVersion = "2022-09-01-preview";
        Risk = "Critical - Circuit breaker functionality will fail"
    },
    @{
        Name = "Microsoft.ApiManagement/service/backends";
        ProblematicVersions = @();
        ContextPattern = "type: 'Pool'";
        RecommendedVersion = "2021-12-01-preview";
        Risk = "Critical - Backend pool functionality will fail"
    }
)

$issues = @()

# Analyze each Bicep file
foreach ($file in $bicepFiles) {
    Write-Host "Analyzing $($file.FullName)..." -ForegroundColor Cyan
    
    $content = Get-Content -Path $file.FullName -Raw
    
    # Check for each potential issue
    foreach ($check in $apiVersionChecks) {
        # If there's a context pattern, first check if the file contains it
        if ($check.ContextPattern -and -not ($content -match $check.ContextPattern)) {
            continue
        }
        
        # Check for problematic versions
        foreach ($version in $check.ProblematicVersions) {
            $pattern = "$($check.Name)@$version"
            if ($content -match $pattern) {
                $issues += @{
                    File = $file.FullName
                    ResourceType = $check.Name
                    CurrentVersion = $version
                    RecommendedVersion = $check.RecommendedVersion
                    Risk = $check.Risk
                }
            }
        }
        
        # If checking for backend pool specifically
        if ($check.ContextPattern -eq "type: 'Pool'" -and $content -match $check.ContextPattern) {
            # Find what version is being used
            if ($content -match "$($check.Name)@([^']*)'.*$($check.ContextPattern)") {
                $usedVersion = $matches[1]
                if ($usedVersion -ne $check.RecommendedVersion) {
                    $issues += @{
                        File = $file.FullName
                        ResourceType = $check.Name + " (Pool)"
                        CurrentVersion = $usedVersion
                        RecommendedVersion = $check.RecommendedVersion
                        Risk = $check.Risk
                    }
                }
            }
        }
    }
}

# Report results
if ($issues.Count -eq 0) {
    Write-Host "`nNo API version issues found! Your deployment should work correctly." -ForegroundColor Green
} else {
    Write-Host "`nFound $($issues.Count) potential API version issues:" -ForegroundColor Yellow
    
    $groupedIssues = $issues | Group-Object -Property File
    
    foreach ($group in $groupedIssues) {
        Write-Host "`nIssues in file: $($group.Name)" -ForegroundColor Yellow
        
        foreach ($issue in $group.Group) {
            Write-Host "  - $($issue.ResourceType): $($issue.CurrentVersion) -> $($issue.RecommendedVersion)" -ForegroundColor Yellow
            Write-Host "    Risk: $($issue.Risk)" -ForegroundColor Red
        }
    }
    
    Write-Host "`nRecommendation: Update the API versions in these files or use the update-api-versions.ps1 script." -ForegroundColor Cyan
}

Write-Host "`nAnalysis complete." -ForegroundColor Cyan
