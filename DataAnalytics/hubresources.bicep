// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------


// Bastion params
param publicIpAddressName string = 'bastionIp'
param bastionname string = 'bastion'

// VM params
param datavm string = 'datavm1'
param vmSize string = 'Standard_D2s_v4'
param adminUsername string = 'datavmadmin'
@secure()
param adminPw string
param location string = 'canadacentral'


resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: 'hub-vnet'
}
resource bastionsubnet 'Microsoft.Network/virtualnetworks/subnets@2015-06-15' existing = {
  parent: vnet
  name: 'AzureBastionSubnet'
}
resource vmsubnet 'Microsoft.Network/virtualnetworks/subnets@2015-06-15' existing = {
  parent: vnet
  name: 'default'
}

resource lzvnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: 'synapseLZ-vnet'
  scope: resourceGroup('SynapseRG')
}

resource publicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bastionname
  location: location
  sku: {
    name: 'Basic'
  }
    properties: {
      ipConfigurations: [
        {
          name: 'IpConf'
          properties: {
            publicIPAddress: {
              id: publicIp.id
            }
            subnet: {
              id: bastionsubnet.id
            }
          }
        }
        ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${datavm}-nic'
  location: location
  properties: {
      enableAcceleratedNetworking: false
      ipConfigurations: [
          {
              name: 'IpConf'
              properties: {
                  subnet: {
                      id: vmsubnet.id
                  }
                  privateIPAllocationMethod: 'Dynamic'
                  privateIPAddressVersion: 'IPv4'
                  primary: true
              }
          }
      ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: datavm
  location: location
  
  properties: {
      hardwareProfile: {
          vmSize: vmSize
      }
      networkProfile: {
          networkInterfaces: [
              {
                  id: nic.id
              }
          ]
      }
      storageProfile: {
          imageReference: {
              publisher: 'MicrosoftWindowsDesktop'
              offer: 'Windows-10'
              sku: '20h1-pro'
              version: 'latest'
          }
          osDisk: {
              name: '${datavm}-os'
              caching: 'ReadWrite'
              createOption: 'FromImage'
              managedDisk: {
                  storageAccountType: 'Premium_LRS'
              }
          }
          dataDisks: [
              {
                  caching: 'None'
                  name: '${datavm}-data-1'
                  diskSizeGB: 128
                  lun: 0
                  managedDisk: {
                      storageAccountType: 'Premium_LRS'
                  }
                  createOption: 'Empty'
              }
          ]
      }
      osProfile: {
          computerName: datavm
          adminUsername: adminUsername
          adminPassword: adminPw
          windowsConfiguration: {
            enableAutomaticUpdates: true
            provisionVMAgent: true
            patchSettings: {
              patchMode: 'AutomaticByOS'              
            }
          }
      }
      
  }
}

resource privsynapsedev 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.dev.azuresynapse.net'
  location: 'Global'
  properties: {}
}

resource privsynapsedevlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privsynapsedevlink'
  location: 'Global' 
  parent: privsynapsedev
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: lzvnet.id
    }
  }
}

resource privsynapsedevlinkhub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privsynapsedevlinkhub'
  location: 'Global' 
  parent: privsynapsedev
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privsynapsesql 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.sql.azuresynapse.net'
  location: 'Global'
  properties: {}
}

resource privsynapsesqllink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privsynapsesqllink'
  location: 'Global' 
  parent: privsynapsesql
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: lzvnet.id
    }
  }
}

resource privsynapsesqllinkhub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privsynapsesqllinkhub'
  location: 'Global' 
  parent: privsynapsesql
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privdfs 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.dfs.core.windows.net'
  location: 'Global'
  properties: {}
}

resource privdfslink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privdfslink'
  location: 'Global' 
  parent: privdfs
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: lzvnet.id
    }
  }
}

resource privdfslinkhub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privdfslinkhub'
  location: 'Global' 
  parent: privdfs
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privadf 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.adf.azure.com'
  location: 'Global'
  properties: {}
}

resource privadflink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privadflink'
  location: 'Global' 
  parent: privadf
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: lzvnet.id
    }
  }
}

resource privadflinkhub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privadflinkhub'
  location: 'Global' 
  parent: privadf
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privanalysis 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.analysis.windows.net'
  location: 'Global'
  properties: {}
}

resource privanalysislink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privanalysislink'
  location: 'Global' 
  parent: privanalysis
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: lzvnet.id
    }
  }
}

resource privanalysislinkhub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privanalysislinkhub'
  location: 'Global' 
  parent: privanalysis
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privdatafactory 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.datafactory.azure.net'
  location: 'Global'
  properties: {}
}

resource privdatafactorylink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privdatafactorylink'
  location: 'Global' 
  parent: privdatafactory
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: lzvnet.id
    }
  }
}

resource privdatafactorylinkhub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privdatafactorylinkhub'
  location: 'Global' 
  parent: privdatafactory
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privpbi 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.pbidedicated.windows.net'
  location: 'Global'
  properties: {}
}

resource privpbilink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privpbilink'
  location: 'Global' 
  parent: privpbi
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: lzvnet.id
    }
  }
}

resource privpbilinkhub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privpbilinkhub'
  location: 'Global' 
  parent: privpbi
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privpowerquery 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.prod.powerquery.microsoft.com'
  location: 'Global'
  properties: {}
}

resource privpowerquerylink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privpowerquerylink'
  location: 'Global' 
  parent: privpowerquery
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: lzvnet.id
    }
  }
}

resource privpowerquerylinkhub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privpowerquerylinkhub'
  location: 'Global' 
  parent: privpowerquery
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}


