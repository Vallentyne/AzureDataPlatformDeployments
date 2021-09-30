# Brief Description of this scenario

Deploys the following resources:

- Azure Synapse
- Azure Storage Account ADLS gen2
- Azure Data Factory
- Network representing a spoke landing zone
- Network representing a hub
- Virtual machine representing a client PC
- Bastion host
- Private DNS Zones
- Private endpoints for Synapse, Data Factory, storage accounts

## Post Deployment Tasks

Several steps are currently manual:

- Some private endpoint configurations are still not automated.
