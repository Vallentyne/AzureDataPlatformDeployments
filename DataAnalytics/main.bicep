// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------



// Synapse
param azsynapsewksp string
param sqladminname string = 'synapseadmin'
@secure()
param sqladminpw string

param azcvadlsstor string = 'azcvadlstor2'
param adlscontainername string = 'container'


resource adlsstorage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: azcvadlsstor
  location: resourceGroup().location
  identity: {
      type: 'SystemAssigned'
    }
    kind: 'StorageV2'
    sku: {
      name: 'Standard_GRS'
    }
    properties: {
      accessTier: 'Hot'
      isHnsEnabled: true
      minimumTlsVersion: 'TLS1_2'
      supportsHttpsTrafficOnly: true
      allowBlobPublicAccess: false
      encryption: {
        requireInfrastructureEncryption: true
        keySource: 'Microsoft.Storage'
        services: {
          blob: {
            enabled: true
            keyType: 'Account'
          }
          file: {
            enabled: true
            keyType: 'Account'
          }
          queue: {
            enabled: true
            keyType: 'Account'
          }
          table: {
            enabled: true
            keyType: 'Account'
          }
        }
      }
    }
    resource blob 'blobservices' = {
      name: 'default'
      properties: {      }
      resource storcontainer 'containers' = {
      name: adlscontainername
        properties: {
        metadata: {}
        publicAccess: 'None'
    }
  }
}
}

resource azsynapse 'Microsoft.Synapse/workspaces@2021-06-01-preview' = {
  name: azsynapsewksp
  location: resourceGroup().location
    identity: {
      type: 'SystemAssigned'
      }
    properties: {
      connectivityEndpoints: {}
      cspWorkspaceAdminProperties: {
        initialWorkspaceAdminObjectId: 'string'
        }
      defaultDataLakeStorage: {
        accountUrl: adlsstorage.properties.primaryEndpoints.dfs
        filesystem: adlscontainername
      }

      managedResourceGroupName: '${resourceGroup().name}-${azsynapsewksp}'
      managedVirtualNetwork: 'default'
      
      publicNetworkAccess: 'Disabled'
      sqlAdministratorLogin: sqladminname
      sqlAdministratorLoginPassword: sqladminpw

      virtualNetworkProfile: {
        computeSubnetId: ''
      }
      
    }
  }
