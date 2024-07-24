param hubVnetName string = 'hub-vnet'
param hubSubnetName string = 'hub-subnet'
param devVnetName string = 'dev-vnet'
param devSubnetName string = 'dev-subnet'
param stageVnetName string = 'stage-vnet'
param stageSubnetName string = 'stage-subnet'
param prodVnetName string = 'prod-vnet'
param prodSubnetName string = 'prod-subnet'
param location string = 'westeurope'
param aksClusterNamePrefix string = 'pvaks-'
var environmentName = 'dev' 
var uniqueId = '001' 
var aksClusterName = '${aksClusterNamePrefix}-${environmentName}-${uniqueId}'


// Hub Virparam aksClusterNamePrefix string
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: hubSubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

// Dev Virtual Network
resource devVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: devVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: devSubnetName
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

// Stage Virtual Network
resource stageVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: stageVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
    subnets: [
      {
        name: stageSubnetName
        properties: {
          addressPrefix: '10.2.1.0/24'
        }
      }
    ]
  }
}

// Prod Virtual Network
resource prodVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: prodVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }
    subnets: [
      {
        name: prodSubnetName
        properties: {
          addressPrefix: '10.3.1.0/24'
        }
      }
    ]
  }
}

// VNet Peerings
resource hubToDevPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: 'hub-to-dev'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: devVnet.id
    }
  }
  parent: hubVnet
}

resource hubToStagePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: 'hub-to-stage'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: stageVnet.id
    }
  }
  parent: hubVnet
}

resource hubToProdPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: 'hub-to-prod'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: prodVnet.id
    }
  }
  parent: hubVnet
}

resource devSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: 'dev-subnet'
  parent: devVnet
}

// Correctly associating a resource with the existing subnet
resource myServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: 'myServicePrivateEndpoint'
  location: 'eastus'
  properties: {
    // Other properties
    subnet: {
      id: devSubnet.id
    }
  }
}
// 1. Managed Identity for AKS
resource devManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'aksManagedIdentity-dev' // Use unique name per environment
  location: location
}

// 2. AKS Cluster in a Spoke VNET
resource devAksCluster 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned' // Use system-assigned managed identity
  }
  properties: {
    dnsPrefix: 'devAksCluster'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        vmSize: 'Standard_B2s'
        count: 1
        osType: 'Linux'
        vnetSubnetID: devVnet.properties.subnets[0].id
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      dnsServiceIP: '10.1.1.10'
      serviceCidr: '10.1.1.0/24'
      podCidr: '172.17.0.1/16'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
  }
}

// 2. Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: 'devAcr'
  location: location
  properties: {
    adminUserEnabled: false
  }
  sku: {
    name: 'Basic'
  }
}



// Private DNS Zone for AKS
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.westeurope.azmk8s.io' // Replace <region> with the Azure region of your AKS clusters, e.g., westus2.azmk8s.io
  location: 'global'
}

// Public IP Address for NAT Gateway
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'aksPublicIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
  // NAT Gateway for outbound connectivity
resource natGateway 'Microsoft.Network/natGateways@2021-02-01' = {
  name: 'aksNatGateway'
  location: location
  properties: {
    publicIpAddresses: [
      {
        id: publicIp.id
      }
    ]
  }
  sku: {
    name: 'Standard'
  }
}

// Associate NAT Gateway with Dev VNet Subnet (Repeat for Stage and Prod as needed)
resource devSubnetNatGateway 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: devSubnetName
  parent: devVnet
  properties: {
    natGateway: {
      id: natGateway.id
    }
  }
}

// Private Link for Azure Container Registry (ACR)
resource acrPrivateLink 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: 'acrPrivateEndpoint'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'acrConnection'
        properties: {
          privateLinkServiceId: acr.id // Assumes acr resource is defined elsewhere in your Bicep file
          groupIds: [
            'registry'
          ]
        }
      }
    ]
    subnet: {
      id: devSubnet.id // Assumes devSubnet resource is defined elsewhere in your Bicep file
    }
  }
}
