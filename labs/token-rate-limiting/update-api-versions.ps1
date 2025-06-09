# PowerShell script to fix API version issues in Bicep files
# This script updates API versions in APIM-related Bicep files to ensure compatibility

param(
    [Parameter(Mandatory=$false)]
    [string]$ModulesPath = "..\..\modules",
    
    [Parameter(Mandatory=$false)]
    [switch]$BackupFiles
)

$ErrorActionPreference = "Stop"

Write-Host "Starting API version update for Azure Gateway labs..." -ForegroundColor Green

# Version mapping for different resource types
$versionMappings = @{
    "Microsoft.ApiManagement/service" = "2021-12-01-preview"
    "Microsoft.ApiManagement/service/apis" = "2021-12-01-preview"
    "Microsoft.ApiManagement/service/apis/policies" = "2021-12-01-preview"
    "Microsoft.ApiManagement/service/apis/diagnostics" = "2021-12-01-preview"
    "Microsoft.ApiManagement/service/backends" = "2022-09-01-preview"
    "Microsoft.ApiManagement/service/subscriptions" = "2021-12-01-preview"
    "Microsoft.ApiManagement/service/loggers" = "2021-12-01-preview"
}

# Special case for backend pools that need type and pool properties
$backendPoolSpecialCase = @{
    "Pattern" = "resource\s+\w+\s+'Microsoft\.ApiManagement/service/backends@[^']*'[^{]*\{[^}]*type:\s*'Pool'"
    "TargetVersion" = "2021-12-01-preview"
}

# Function to create a backup of a file
function Backup-File {
    param (
        [string]$FilePath
    )
    
    if ($BackupFiles) {
        $backupPath = "$FilePath.bak"
        Copy-Item -Path $FilePath -Destination $backupPath -Force
        Write-Host "Created backup at $backupPath" -ForegroundColor Cyan
    }
}

# Function to update API versions in a file
function Update-ApiVersions {
    param (
        [string]$FilePath
    )
    
    # Check if file exists
    if (-not (Test-Path $FilePath)) {
        Write-Host "Warning: File $FilePath does not exist, skipping." -ForegroundColor Yellow
        return $false
    }
    
    # Create backup if requested
    Backup-File -FilePath $FilePath
    
    # Read file content
    $content = Get-Content $FilePath -Raw
    $originalContent = $content
    $changed = $false
    
    # Process regular version mappings
    foreach ($resourceType in $versionMappings.Keys) {
        $targetVersion = $versionMappings[$resourceType]
        
        # Look for problematic versions and update them
        $problematicVersions = @("2022-08-01", "2023-05-01", "2023-09-01", "2024-05-01")
        
        foreach ($version in $problematicVersions) {
            $pattern = "$resourceType@$version"
            if ($content -match $pattern) {
                Write-Host "  - Updating $pattern to $resourceType@$targetVersion" -ForegroundColor Yellow
                $content = $content -replace "$resourceType@$version", "$resourceType@$targetVersion"
                $changed = $true
            }
        }
    }
    
    # Special case for backend pool with type and pool properties
    if ($content -match $backendPoolSpecialCase.Pattern) {
        $match = [regex]::Match($content, "resource\s+(\w+)\s+'Microsoft\.ApiManagement/service/backends@([^']*)'")
        if ($match.Success) {
            $resourceName = $match.Groups[1].Value
            $currentVersion = $match.Groups[2].Value
            
            if ($currentVersion -ne $backendPoolSpecialCase.TargetVersion) {
                Write-Host "  - Updating backend pool resource $resourceName from version $currentVersion to $($backendPoolSpecialCase.TargetVersion)" -ForegroundColor Yellow
                $content = $content -replace "resource\s+$resourceName\s+'Microsoft\.ApiManagement/service/backends@[^']*'", "resource $resourceName 'Microsoft.ApiManagement/service/backends@$($backendPoolSpecialCase.TargetVersion)'"
                $changed = $true
            }
        }
    }
    
    # Write changes back to file if anything was changed
    if ($changed) {
        Set-Content -Path $FilePath -Value $content
        Write-Host "Updated API versions in $FilePath" -ForegroundColor Green
        return $true
    } else {
        Write-Host "No API version changes needed in $FilePath" -ForegroundColor Green
        return $false
    }
}

# Find all Bicep files in the modules path
$bicepFiles = Get-ChildItem -Path $ModulesPath -Filter "*.bicep" -Recurse -File | Where-Object {
    # Filter to focus on likely APIM-related files
    $_.Name -like "*api*.bicep" -or 
    $_.Name -like "*apim*.bicep" -or
    $_.DirectoryName -like "*apim*"
}

if ($bicepFiles.Count -eq 0) {
    Write-Host "No relevant Bicep files found in $ModulesPath" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($bicepFiles.Count) relevant Bicep files to check." -ForegroundColor Cyan

$updatedFiles = 0

# Process each file
foreach ($file in $bicepFiles) {
    Write-Host "Processing $($file.FullName)..." -ForegroundColor Cyan
    $result = Update-ApiVersions -FilePath $file.FullName
    if ($result) {
        $updatedFiles++
    }
}

# Special case for openai-api.bicep which is the most critical file
$openaiApiPath = "$ModulesPath\apim\v1\openai-api.bicep"
if (Test-Path $openaiApiPath) {
    Write-Host "Processing key file $openaiApiPath..." -ForegroundColor Cyan
    $result = Update-ApiVersions -FilePath $openaiApiPath
    if ($result) {
        $updatedFiles++
    }
}

# Also check apim.bicep which is important
$apimPath = "$ModulesPath\apim\v1\apim.bicep"
if (Test-Path $apimPath) {
    Write-Host "Processing key file $apimPath..." -ForegroundColor Cyan
    $result = Update-ApiVersions -FilePath $apimPath
    if ($result) {
        $updatedFiles++
    }
}

Write-Host "`nAPI version update completed. Updated $updatedFiles files." -ForegroundColor Green

if ($updatedFiles -gt 0) {
    Write-Host "You can now run the deployment again." -ForegroundColor Green
    Write-Host "Note: Using API version 2021-12-01-preview ensures compatibility with 'type' and 'pool' properties in backend resources." -ForegroundColor Yellow
    Write-Host "      Using API version 2022-09-01-preview ensures compatibility with circuit breaker functionality." -ForegroundColor Yellow
} else {
    Write-Host "No files needed updating. Your Bicep files should already have compatible API versions." -ForegroundColor Green
}
