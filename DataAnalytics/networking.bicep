// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param location string = 'canadacentral'

// VNET
param vnetName string
param vnetAddressSpace string

// Virtual Appliance IP
param egressVirtualApplianceIp string

// Internal Foundational Elements (OZ) Subnet
param subnetFoundationalElementsName string
param subnetFoundationalElementsPrefix string

// Presentation Zone (PAZ) Subnet
param subnetPresentationName string
param subnetPresentationPrefix string

// Azure PaaS private endpoint subnet
param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string



// Route Tables
resource udrApplication 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetPresentationName}Udr'
  location: location
  properties: {
    routes: [
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: subnetFoundationalElementsName
        properties: {
          addressPrefix: subnetFoundationalElementsPrefix
        }        
      }
      {
        name: subnetPresentationName
        properties: {
          addressPrefix: subnetPresentationPrefix
        }
      }
      
      {
        name: subnetPrivateEndpointsName
        properties: {
          addressPrefix: subnetPrivateEndpointsPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}





output vnetId string = vnet.id

output foundationalElementSubnetId string = '${vnet.id}/subnets/${subnetFoundationalElementsName}'
output presentationSubnetId string = '${vnet.id}/subnets/${subnetPresentationName}'
output privateEndpointSubnetId string = '${vnet.id}/subnets/${subnetPrivateEndpointsName}'


