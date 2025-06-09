# Token Rate Limiting Lab - Fix Summary

## Problem Addressed

The token-rate-limiting lab was experiencing deployment failures due to API version compatibility issues with Microsoft.ApiManagement resources. Specifically:

1. Circuit breaker functionality requires API version 2022-09-01-preview or newer
2. API versions 2023-05-01 and 2024-05-01 are not available in all regions
3. Backend pool properties like "type" and "pool" require API version 2021-12-01-preview

## Solution Implemented

### Updated Files

1. **Updated Notebook**
   - Added explanatory cells about API version issues
   - Added code cells to run the PowerShell scripts
   - Added references to documentation

2. **Created PowerShell Scripts**
   - `update-api-versions.ps1`: Automatically updates API versions in Bicep files
   - `verify-api-versions.ps1`: Checks that API versions are correctly updated
   - `diagnose-api-versions.ps1`: General-purpose diagnostic tool for API version issues

3. **Created Documentation**
   - `bicep-troubleshooting.md`: Detailed guide for resolving API version issues
   - `bicep-fix-notes.md`: Summary of all changes made
   - `deployment-verification.md`: Steps to verify the deployment after fixes
   - `lab-comparison.md`: Comparison with token-metrics-emitting lab

### API Version Changes

The following API version changes were implemented:

| Resource | Original Version | Updated Version |
|----------|-----------------|-----------------|
| Microsoft.ApiManagement/service | 2023-05-01/2024-05-01 | 2021-12-01-preview |
| Microsoft.ApiManagement/service/apis | 2023-05-01/2024-05-01 | 2021-12-01-preview |
| Microsoft.ApiManagement/service/apis/policies | 2022-08-01 | 2021-12-01-preview |
| Microsoft.ApiManagement/service/backends (with circuit breaker) | 2022-08-01 | 2022-09-01-preview |
| Microsoft.ApiManagement/service/backends (backend pool) | various | 2021-12-01-preview |

## Verification Process

1. Run the PowerShell update script to change API versions
2. Run the verification script to confirm changes
3. Deploy the updated lab
4. Verify resources are created successfully
5. Test token rate limiting functionality

## Extended Impact

The solution provided:

1. Fixes for the token-rate-limiting lab
2. Diagnostic tools applicable to other labs
3. Documentation to help understand and address similar issues
4. Comparison with the token-metrics-emitting lab to show patterns

## Future-proofing

While the current fix uses specific API versions (2021-12-01-preview and 2022-09-01-preview), the diagnostic tool and documentation provide guidance for handling API version changes in the future. As Azure API Management evolves, these resources will help quickly adapt to new API versions.
