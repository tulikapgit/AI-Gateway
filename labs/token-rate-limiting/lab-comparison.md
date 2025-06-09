# Comparison: Token Rate Limiting vs. Token Metrics Emitting Labs

Both the Token Rate Limiting and Token Metrics Emitting labs faced similar API version compatibility issues. This document compares the two labs to help understand the common patterns and specific differences.

## Common Issues

| Issue | Token Rate Limiting | Token Metrics Emitting | Solution |
|-------|---------------------|------------------------|----------|
| Circuit Breaker API Version | Required newer version than 2022-08-01 | Required newer version than 2022-08-01 | Update to 2022-09-01-preview |
| API Version Registration | 2023-05-01/2024-05-01 not available in all regions | 2023-05-01/2024-05-01 not available in all regions | Downgrade to 2021-12-01-preview |
| Backend Pool Properties | Required specific API version for `type` and `pool` | Required specific API version for `type` and `pool` | Use 2021-12-01-preview specifically for backend pool |

## Lab-Specific Features

| Feature | Token Rate Limiting | Token Metrics Emitting |
|---------|---------------------|------------------------|
| Main APIM Policy | `azure-openai-token-limit` | `azure-openai-token-measure` |
| Policy Function | Limits token usage to prevent overages | Measures and emits token usage metrics |
| Usage Pattern | Rejects requests after threshold | Allows all requests but tracks usage |
| Test Pattern | Sends multiple requests until rate limited | Sends requests and checks Application Insights |

## Fixes Applied

| Fix | Token Rate Limiting | Token Metrics Emitting |
|-----|---------------------|------------------------|
| Backend API Version | 2022-08-01 → 2022-09-01-preview | 2022-08-01 → 2022-09-01-preview |
| APIM Service API Version | 2023-05-01 → 2021-12-01-preview | 2023-05-01 → 2021-12-01-preview |
| APIM APIs API Version | 2023-05-01 → 2021-12-01-preview | 2023-05-01 → 2021-12-01-preview |
| Backend Pool API Version | Various → 2021-12-01-preview | Various → 2021-12-01-preview |
| Documentation | Added troubleshooting guide | Added troubleshooting guide |
| Automation | Added PowerShell fix script | Added PowerShell fix script |

## Deployment Validation

Both labs require similar validation steps:

1. Verify correct API versions in Bicep files
2. Deploy the lab resources
3. Verify resource creation in Azure
4. Test the specific APIM policy functionality
5. Analyze the results (rate limiting or metrics)

## Recommendations for Other Labs

If you encounter similar issues in other labs, follow this general approach:

1. Identify the API version compatibility issues in error messages
2. Update backend resources to API version 2022-09-01-preview or newer for circuit breaker functionality
3. Update all other APIM resources to 2021-12-01-preview for maximum compatibility
4. Use specific API versions for specialized resources (like backend pools)
5. Add verification steps to confirm the changes fixed the issues

This pattern should resolve most API version compatibility issues across all the labs in this repository.
