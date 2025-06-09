# Token Rate Limiting Lab - Bicep Deployment Troubleshooting Guide

## Problem Overview

The Token Rate Limiting lab may fail during Bicep deployment with errors related to API versions. The main issues are:

1. **Circuit Breaker Support Issue**: Error message states "Circuit breaker is supported for API versions greater or equal to 2022-09-01 preview."

2. **API Version Registration Issue**: Error message states "NoRegisteredProviderFound for location 'uksouth' and API version '2023-05-01' for type 'service'."

3. **Backend Pool Properties Issue**: The backend pool resource using properties like `type` and `pool` requires a specific API version.

## Root Causes

1. The API versions (2023-05-01, 2024-05-01) used in the Bicep files might not be available or registered in your Azure subscription or region.

2. The circuit breaker functionality requires at least API version 2022-09-01-preview.

3. The backend pool properties (`type` and `pool`) are only supported in specific API versions, particularly 2021-12-01-preview.

## Solution

### Automated Fix

1. Run the provided PowerShell script `update-api-versions.ps1` that automatically updates all API versions in the relevant Bicep files:

```powershell
.\update-api-versions.ps1
```

### Manual Fix

If you prefer to make the changes manually:

1. Open `modules/apim/v1/openai-api.bicep`

2. Update API versions as follows:
   - Change `Microsoft.ApiManagement/service@2023-05-01` to `Microsoft.ApiManagement/service@2021-12-01-preview`
   - Change `Microsoft.ApiManagement/service/apis@2023-05-01` to `Microsoft.ApiManagement/service/apis@2021-12-01-preview`
   - Change `Microsoft.ApiManagement/service/apis/policies@2022-08-01` to `Microsoft.ApiManagement/service/apis/policies@2021-12-01-preview`
   - Change `Microsoft.ApiManagement/service/backends@2022-08-01` to `Microsoft.ApiManagement/service/backends@2022-09-01-preview`
   - Ensure the backend pool uses `Microsoft.ApiManagement/service/backends@2021-12-01-preview`

3. Also check and update API versions in `modules/apim/v1/apim.bicep` if needed.

## Verification

After applying the fixes, run the deployment again. If successful, you should see:

1. API Management service created
2. OpenAI services provisioned
3. Backend services and policies configured correctly

## Additional Notes

- API version 2021-12-01-preview is recommended for most API Management resources in this lab
- API version 2022-09-01-preview or newer is required specifically for backends with circuit breaker functionality
- API version 2021-12-01-preview is required specifically for backend pool with `type` and `pool` properties
- Future updates to the Azure API Management resource provider may resolve these issues, but these fixes provide compatibility with current deployments
