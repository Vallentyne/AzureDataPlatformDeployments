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

resource publicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: publicIpAddressName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bastionname
  location: resourceGroup().location
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
  location: resourceGroup().location
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
  location: resourceGroup().location
  
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

resource privsynapse 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azuresynapse.net'
  location: 'Global'
  properties: {}
}

resource privsynapsedev 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.dev.azuresynapse.net'
  location: 'Global'
  properties: {}
}

resource privsynapsesql 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.sql.azuresynapse.net'
  location: 'Global'
  properties: {}
}

resource privdfs 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.dfs.core.windows.net'
  location: 'Global'
  properties: {}
}

resource privadf 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.adf.azure.com'
  location: 'Global'
  properties: {}
}

resource privanalysis 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.analysis.windows.net'
  location: 'Global'
  properties: {}
}

resource privdatafactory 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.datafactory.azure.net'
  location: 'Global'
  properties: {}
}

resource privpbi 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.pbidedicated.windows.net'
  location: 'Global'
  properties: {}
}

resource privpowerquery 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.prod.powerquery.microsoft.com'
  location: 'Global'
  properties: {}
}



