param hubVnetName string = 'hub-vnet'
param hubSubnetName string = 'hub-subnet'
param devVnetName string = 'dev-vnet'
param devSubnetName string = 'dev-subnet'
param stageVnetName string = 'stage-vnet'
param stageSubnetName string = 'stage-subnet'
param prodVnetName string = 'prod-vnet'
param prodSubnetName string = 'prod-subnet'
param location string = 'westus2'
param aksClusterNamePrefix string = 'aks-'

// Hub Virtual Network
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
  location: location
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
  location: location
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
  location: location
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

// AKS Clusters in Spoke VNets
resource devAksCluster 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
  name: '${aksClusterNamePrefix}dev'
  location: location
  properties: {
    # ... other AKS cluster properties
    networkProfile: {
      networkPlugin: 'azure'
      podCidr: '10.1.2.0/24'
      serviceCidr: '10.1.3.0/24'
      dnsServiceIP: '10.1.3.10'
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {
        managedOutboundIPs: {
          count: 2
        }
        outboundIPPrefixes: {
          publicIPPrefixes: [
            {
              name: 'aks-agentpool-outbound-pip-prefix'
            }
          ]
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'default'
        # ... other agent pool properties
        vnetSubnetID: devVnet.properties.subnets[0].id
      }
    ]
  }
}

// Stage AKS Cluster
resource stageAksCluster 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
  name: '${aksClusterNamePrefix}stage'
  location: location
  properties: {
    # ... other AKS cluster properties
    networkProfile: {
      networkPlugin: 'azure'
      podCidr: '10.2.2.0/24'
      serviceCidr: '10.2.3.0/24'
      dnsServiceIP: '10.2.3.10'
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {
        managedOutboundIPs: {
          count: 2
        }
        outboundIPPrefixes: {
          publicIPPrefixes: [
            {
              name: 'aks-agentpool-outbound-pip-prefix'
            }
          ]
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'default'
        # ... other agent pool properties
        vnetSubnetID: stageVnet.properties.subnets[0].id
      }
    ]
  }
}

// Prod AKS Cluster
resource prodAksCluster 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
  name: '${aksClusterNamePrefix}prod'
  location: location
  properties: {
    # ... other AKS cluster properties
    networkProfile: {
      networkPlugin: 'azure'
      podCidr: '10.3.2.0/24'
      serviceCidr: '10.3.3.0/24'
      dnsServiceIP: '10.3.3.10'
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {
        managedOutboundIPs: {
          count: 2
        }
        outboundIPPrefixes: {
          publicIPPrefixes: [
            {
              name: 'aks-agentpool-outbound-pip-prefix'
            }
          ]
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'default'
        # ... other agent pool properties
        vnetSubnetID: prodVnet.properties.subnets[0].id
      }
    ]
  }
}
