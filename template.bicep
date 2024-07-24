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

resource hubVnetName_hub_to_dev 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  parent: hubVnet
  name: 'hub-to-dev'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: devVnet.id
    }
  }
}

resource hubVnetName_hub_to_stage 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  parent: hubVnet
  name: 'hub-to-stage'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: stageVnet.id
    }
  }
}

resource hubVnetName_hub_to_prod 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  parent: hubVnet
  name: 'hub-to-prod'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: prodVnet.id
    }
  }
}

resource myServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: 'myServicePrivateEndpoint'
  location: 'eastus'
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', devVnetName, 'dev-subnet')
    }
  }
  dependsOn: [
    devVnet
  ]
}

resource aksManagedIdentity_dev 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'aksManagedIdentity-dev'
  location: location
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'devAksCluster'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        vmSize: 'Standard_B2s'
        count: 1
        osType: 'Linux'
        vnetSubnetID: reference(devVnet.id, '2023-02-01').subnets[0].id
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

resource devAcr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: 'devAcr'
  location: location
  properties: {
    adminUserEnabled: false
  }
  sku: {
    name: 'Basic'
  }
}

resource privatelink_westeurope_azmk8s_io 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.westeurope.azmk8s.io'
  location: 'global'
}

resource aksPublicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'aksPublicIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource aksNatGateway 'Microsoft.Network/natGateways@2021-02-01' = {
  name: 'aksNatGateway'
  location: location
  properties: {
    publicIpAddresses: [
      {
        id: aksPublicIP.id
      }
    ]
  }
  sku: {
    name: 'Standard'
  }
}

resource devVnetName_devSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: devVnet
  name: '${devSubnetName}'
  properties: {
    natGateway: {
      id: aksNatGateway.id
    }
  }
}

resource acrPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: 'acrPrivateEndpoint'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'acrConnection'
        properties: {
          privateLinkServiceId: devAcr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', devVnetName, 'dev-subnet')
    }
  }
  dependsOn: [
    devVnet
  ]
}
