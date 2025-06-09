# Bicep Deployment Troubleshooting Guide

## API Version Compatibility Issues

When deploying the token-metrics-emitting lab, you may encounter warnings like:

```
Warning BCP081: Resource type "Microsoft.ApiManagement/service@2023-05-01" does not have types available.
Warning BCP037: The property "type" is not allowed on objects of type "BackendContractProperties".
Warning BCP037: The property "pool" is not allowed on objects of type "BackendContractProperties".
```

## Root Cause

These errors occur because:
1. Newer API versions (2023-05-01, 2024-05-01) don't have schema information available in Bicep.
2. Some properties (like `type` and `pool` on backend resources) are only supported in specific API versions.

## Quick Fix

Update your Bicep files to use API version `2021-12-01-preview` instead of newer versions:

1. For Microsoft.ApiManagement/service resources
2. For Microsoft.ApiManagement/service/apis resources
3. For Microsoft.ApiManagement/service/backends resources
4. For Microsoft.ApiManagement/service/subscriptions resources

## Automated Fix

You can use the PowerShell script in the notebook to automatically update all API versions to compatible ones.

## Files to Update

- `modules/apim/v1/openai-api.bicep`
- `labs/token-metrics-emitting/main.bicep`

## Known Limitations

- Even after these changes, you may still see BCP081 warnings, but they shouldn't prevent successful deployment.
- Non-critical warnings about location parameters can be ignored.

## Future Considerations

As Bicep evolves, newer API versions will eventually have schema information available. You may want to check periodically if you can update back to more recent API versions.
