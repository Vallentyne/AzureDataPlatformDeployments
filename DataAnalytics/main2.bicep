// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Synapse Analytics name.')
param name string

@description('Synapse Analytics Managed Resource Group Name.')
param managedResourceGroupName string

@description('Azure Data Lake Store Gen2 Name.')
param adlsName string

@description('Azure Data Lake Store File System Name.')
param adlsFSName string

param Datafactory string

// Credentials
@description('Synapse Analytics Username.')
@secure()
param synapseUsername string

@description('Synapse Analytics Password.')
@secure()
param synapsePassword string

// Networking
param hubrgname string


resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: 'synapseLZ-vnet'
}
resource privendsubnet 'Microsoft.Network/virtualnetworks/subnets@2015-06-15' existing = {
  parent: vnet
  name: 'PrivEndpoints'
}

resource synapsePrivateZoneId 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(hubrgname)
  name: 'privatelink.azuresynapse.net'
}

resource synapsedevPrivateZoneId 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(hubrgname)
  name: 'privatelink.dev.azuresynapse.net'
}

resource adfPortalPrivateZoneId 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(hubrgname)
  name: 'privatelink.adf.azure.com'
}

resource adfPrivateZoneId 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(hubrgname)
  name: 'privatelink.datafactory.azure.net'
}

resource adlsstorage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: adlsName
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
      name: adlsFSName
        properties: {
        metadata: {}
        publicAccess: 'None'
    }
  }
}
}


resource synapsePrivateLinkHub 'Microsoft.Synapse/privateLinkHubs@2021-03-01' = {
  name: '${toLower(name)}plhub'
  location: resourceGroup().location
}

resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' = {
  dependsOn: [
    adlsstorage
    
  ]
  name: name
  location: resourceGroup().location
  properties: {
    sqlAdministratorLoginPassword: synapsePassword
    managedResourceGroupName: managedResourceGroupName
    sqlAdministratorLogin: synapseUsername

    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      preventDataExfiltration: true
    }

    publicNetworkAccess: 'Disabled'

    defaultDataLakeStorage: {
      accountUrl: adlsstorage.properties.primaryEndpoints.dfs
      filesystem: adlsFSName
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

  // Assign the workspace's system-assigned managed identity CONTROL permissions to SQL pools for pipeline integration
  resource synapse_msi_sql_control_settings 'managedIdentitySqlControlSettings@2021-05-01' = {
    name: 'default'
    properties: {
      grantSqlControlToManagedIdentity: {
        desiredState: 'Enabled'
      }
    }
  }

  resource synapse_audit 'auditingSettings@2021-05-01' = {
    name: 'default'
    properties: {
      isAzureMonitorTargetEnabled: true
      state: 'Enabled'
    }
  }

  resource synapse_securityAlertPolicies 'securityAlertPolicies@2021-05-01' = {
    name: 'Default'
    properties: {
      state: 'Enabled'
      emailAccountAdmins: false
    }
  }
}

resource synapse_workspace_web_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${synapse.name}-web-endpoint'
  properties: {
    subnet: {
      id: privendsubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-web-endpoint'
        properties: {
          privateLinkServiceId: synapsePrivateLinkHub.id
          groupIds: [
            'web'
          ]
        }
      }
    ]
  }
}

resource synapse_workspace_dev_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${synapse.name}-workspace-dev-endpoint'
  properties: {
    subnet: {
      id: privendsubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-workspace-dev-endpoint'
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            'dev'
          ]
        }
      }
    ]
  }
}

  resource synapse_workspace_sql_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
    location: resourceGroup().location
    name: '${synapse.name}-workspace-sql-endpoint'
    properties: {
      subnet: {
        id: privendsubnet.id
      }
      privateLinkServiceConnections: [
        {
          name: '${synapse.name}-workspace-sql-endpoint'
          properties: {
            privateLinkServiceId: synapse.id
            groupIds: [
              'sql'
            ]
          }
        }
      ]
    }
  }

  resource synapse_workspace_dev_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
    parent: synapse_workspace_dev_pe
    name: '${synapse.name}-dev-reg'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-synapse-workspace-dev'
          properties: {
            privateDnsZoneId: synapsePrivateZoneId.id
          }
        }
      ]
    }
  }

  resource synapse_workspace_sql_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
    parent: synapse_workspace_sql_pe
    name: '${synapse.name}-sqlreg'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-synapse-workspace-sql'
          properties: {
            privateDnsZoneId: synapsePrivateZoneId.id
          }
        }
      ]
    }
  }

resource synapse_workspace_sql_on_demand_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${synapse.name}-workspace-sql-ondemand-endpoint'
  properties: {
    subnet: {
      id: privendsubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-workspace-sql-ondemand-endpoint'
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            'sqlondemand'
          ]
        }
      }
    ]
  }
}

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: Datafactory
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }

}

resource datafactoryportalpe 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  location: resourceGroup().location
  name: '${datafactory.name}-portal-privend'
  properties: {
    subnet: {
      id: privendsubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${datafactory.name}-portal-privend'
        properties: {
          privateLinkServiceId: datafactory.id
          groupIds: [
            'portal'
          ]
        }
      }
    ]
  }
}

resource datafactorype 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  location: resourceGroup().location
  name: '${datafactory.name}-privend'
  properties: {
    subnet: {
      id: privendsubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${datafactory.name}-privend'
        properties: {
          privateLinkServiceId: datafactory.id
          groupIds: [
            'datafactory'
          ]
        }
      }
    ]
  }
}

resource datafactory_portal_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: datafactoryportalpe
  name: '${datafactory.name}-portalreg'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-adf-portal'
        properties: {
          privateDnsZoneId: adfPortalPrivateZoneId.id
        }
      }
    ]
  }
}

resource datafactory_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: datafactorype
  name: '${datafactory.name}-reg'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-adf'
        properties: {
          privateDnsZoneId: adfPrivateZoneId.id
        }
      }
    ]
  }
}
