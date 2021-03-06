# Azure Data Platform Deployments

## Data Proof of Concept Environments

These resources assist in accelerating Azure Data projects.  The general solution resembles the following items shown on the right side of this diagram:

![Solution Design](solution.png)

## Security Considerations

Security accreditation of environments that include these Azure resources is a key aspect for many government customers.  These deployments are not intended to solve every security issue, but some typical issues that are important for obtaining PBMM Authority to Operate (ATO) are as follows:

| PBMM Control Name | Description |
| --- | ---------- |
|Location of Assets | All resources are created in Canada Central |
|AU-3 (2), AU-6 (4), AU-12 Auditing and Logging requirements | All deployed resources send logs to a Log Analytics workspace|
|SC-7 Boundary Protection| Azure Bastion is used to protect deployed VM <br> Public endpoints are minimized where possible|
|SC-28 (1) Protection of Information at Rest|Encryption of data at rest is deployed by default|
|SI-4 System Monitoring|Log Analytics/Azure Monitor is the focal point for all logging <br> Azure Monitor alerts <br> Not deployed by this solution, but also possible to leverage is Azure Sentinel|

These controls are also expressed as part of the [Canadian Federal PBMM Azure Blueprint](https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/canada-federal-pbmm/).  The templates here are designed to be compliant with the above controls at least.  Other deployment considerations for Security and core Infrastructure teams might include how these assets integrate with existing Azure deployments.

## Deploy the Environment

This includes the following resources:

- a Log Analytics Workspace,
- virtual network,
- VM for data work,
- Bastion and other components needed for compliance

Data Platform specific resources include:

- Azure Databricks
- SQL Server
- Analysis Server

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVallentyne%2FAzureDataPlatformDeployments%2Fmain%2FInfrabaseline-arm.json)

## Deploy the Environment - v2

This includes the following resources:

- a Log Analytics Workspace,
- virtual network,
- VM for data work,
- Bastion
- Key Vault and other components needed for compliance

Data Platform specific resources include:

- Azure Synapse
- Azure Data Factory
- Azure Data Lake storage
- Azure Databricks

! Note that Azure Synapse is not yet available in Canadian regions of Azure. (as of Fall 2020)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVallentyne%2FAzureDataPlatformDeployments%2Fmain%2FInfraBaseline2-arm.json)

## Deploy the Environment (custom names)- v3

This includes the following resources:

- a Log Analytics Workspace,
- virtual network,
- VM for data work,
- Bastion
- Key Vault and other components needed for compliance

Data Platform specific resources include:

- Azure Data Factory
- Azure Data Lake storage
- Azure Databricks

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVallentyne%2FAzureDataPlatformDeployments%2Fmain%2FInfraBaseline3-arm.json)

## Known Areas to Watch For

- Ensure the subscription has room for quota for these resources.
- Azure Synapse is not yet available in Canadian Data Centers, and so PBMM region controls aren't possible for the deployments that leverage it yet.  (as of Aug 5, 2020)
- Different Azure resources have specific naming rules, be ready to know what they are for this set of resources.
