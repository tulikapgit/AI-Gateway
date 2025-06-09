# PowerShell script to clean up temporary files created during troubleshooting

param(
    [Parameter(Mandatory=$false)]
    [switch]$RemoveBackups,
    
    [Parameter(Mandatory=$false)]
    [switch]$RemoveDiagnostics
)

$ErrorActionPreference = "Stop"

Write-Host "Starting cleanup of troubleshooting files..." -ForegroundColor Cyan

$filesToRemove = @()
$currentDirectory = Get-Location

# Find backup files if requested
if ($RemoveBackups) {
    $backupFiles = Get-ChildItem -Path $currentDirectory -Filter "*.bak" -Recurse -File
    $filesToRemove += $backupFiles
    
    Write-Host "Found $($backupFiles.Count) backup files to remove." -ForegroundColor Yellow
}

# Define diagnostic files that can be safely removed
$diagnosticFiles = @(
    "verify-api-versions.ps1",
    "diagnose-api-versions.ps1"
)

# Find diagnostic files if requested
if ($RemoveDiagnostics) {
    foreach ($file in $diagnosticFiles) {
        $fullPath = Join-Path -Path $currentDirectory -ChildPath $file
        if (Test-Path $fullPath) {
            $filesToRemove += Get-Item -Path $fullPath
        }
    }
    
    Write-Host "Found $($diagnosticFiles.Count) diagnostic files to remove." -ForegroundColor Yellow
}

# Remove the files
if ($filesToRemove.Count -gt 0) {
    foreach ($file in $filesToRemove) {
        Write-Host "Removing $($file.FullName)..." -ForegroundColor Yellow
        Remove-Item -Path $file.FullName -Force
    }
    
    Write-Host "Successfully removed $($filesToRemove.Count) files." -ForegroundColor Green
} else {
    Write-Host "No files to remove." -ForegroundColor Green
}

Write-Host "Cleanup complete." -ForegroundColor Cyan
Write-Host "Note: Documentation files (*.md) were preserved as they contain valuable troubleshooting information." -ForegroundColor Yellow
