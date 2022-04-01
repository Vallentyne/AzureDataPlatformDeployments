# Brief Description of this scenario

Deploys the following resources:

- Azure Synapse
- Azure Storage Account ADLS gen2
- Azure Data Factory
- Network representing a spoke landing zone
- Network representing a hub
- Virtual machine representing a client PC
- Bastion host
- Private DNS Zones, linked to both networks
- Private endpoints for Synapse, Data Factory, storage accounts

## Deploy

Run the deploy script from a logged in Azure powershell instance.
