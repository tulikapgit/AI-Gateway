# Deployment Verification for Token Rate Limiting Lab

This document provides steps to verify that your deployment is working correctly after applying the API version fixes.

## Pre-deployment Verification

1. Run the `verify-api-versions.ps1` script to confirm all API versions have been updated correctly
2. Check that the Bicep files no longer contain incompatible API versions

## Post-deployment Verification

After successfully deploying the lab, follow these steps to verify everything is working correctly:

### 1. Verify Resource Creation

Run this Azure CLI command to list all resources in your resource group:

```powershell
az resource list --resource-group lab-token-rate-limiting --output table
```

You should see:
- API Management service
- OpenAI service with the correct model deployment
- Related resources (Application Insights, etc.)

### 2. Verify API Management Configuration

Run this command to get information about your API Management service:

```powershell
az apim show --name apim-* --resource-group lab-token-rate-limiting
```

Check that:
- The service is in "Succeeded" state
- The correct SKU is being used

### 3. Verify Backend Configuration

1. Open the Azure Portal
2. Navigate to your API Management service
3. Go to APIs > OpenAI > Settings
4. Verify the API specification is loaded correctly
5. Check the backend configuration points to your OpenAI endpoint

### 4. Test the Rate Limiting

Execute the testing cells in the notebook to verify:
- First few requests succeed (status code 200)
- After reaching the token limit, requests are rejected (status code 429)
- The token accumulation graph displays correctly

### 5. Verify Circuit Breaker

To test the circuit breaker functionality:
1. Run this code multiple times to trigger rate limiting repeatedly:
```python
for i in range(5):
    response = requests.post(url, headers = {'api-key':apim_subscription_key}, json = messages)
    print(f"Request {i+1}: Status {response.status_code}")
    time.sleep(1)
```

2. After seeing multiple 429 responses, the circuit breaker should open
3. Check that after the circuit breaker trip duration (1 minute by default), requests can succeed again

## Troubleshooting Failed Verification

If verification fails:

1. Check the API Management diagnostic logs
2. Verify the managed identity permissions are correctly set up
3. Validate the policy XML configuration
4. Try deploying in a different region
5. Check Azure health status for any service outages

For persistent issues, consult the [Azure API Management troubleshooting guide](https://learn.microsoft.com/azure/api-management/api-management-troubleshoot-common-issues)
