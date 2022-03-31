
#az group create --location canadacentral --resource-group SynapseRG
#az group create --location canadacentral --resource-group SynHubRG


az deployment group create --resource-group SynapseRG --template-file .\networking.bicep --parameters .\networking-syn.parameters.json

az deployment group create --resource-group SynHubRG --template-file .\networking.bicep --parameters .\networking-hub.parameters.json

az deployment group create --resource-group SynHubRG --template-file .\hubresources.bicep

az deployment group create --resource-group SynapseRG --template-file .\main2.bicep --parameters .\main2.parameters.json

