# Azure Data Platform Deployments

## Data Proof of Concept Environments

These resources assist in accelerating Azure Data projects.

## Security Considerations

Security accreditation of environments that include these Azure resources is a key aspect for many government customers.  These deployments are not intended to solve every security issue, but some typical issues that are important for obtaining PBMM Authority to Operate (ATO) are as follows:

| PBMM Control Name | Description |
| --- | ---------- |
|Location of Assets | All resources are created in Canada East |
|AU-3 (2), AU-6 (4), AU-12 Auditing and Logging requirements | all deployed resources send logs to a Log Analytics workspace|
|SC-5 Denial of Service| DDOS policy is created and assigned to deployed VNET|
|SC-7 Boundary Protection| Azure Bastion is used to protect deployed VM <br> Public endpoints are minimized where possible|
|SC-28 (1) Protection of Information at Rest|Encryption of data at rest is deployed by default|
|SI-4 System Monitoring|Log Analytics/Azure Monitor is the focal point for all logging <br> Azure Monitor alerts <br> Not deployed by this solution, but also possible to leverage is Azure Sentinel|

These controls are also expressed as part of the [Canadian Federal PBMM Azure Blueprint](https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/canada-federal-pbmm/).  The templates here are designed to be compliant with the above controls at least.  Other deployment considerations for Security and core Infrastructure teams might be how these assets integrate with existing Azure deployments.

## Deploy the Environment

If you have been delegated a resource group in an existing subscription use this deployment:

### Deploy the SQL DW

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVallentyne%2FAzureDataPlatformDeployments%2Fmaster%2FSQLDW-arm.json)

If you have been delegated a subscription to deploy these resources, use this deployment:
