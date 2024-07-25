targetScope = 'subscription'

@description('Name of the environment that can be used as part of naming resource convention')
@minLength(1)
@maxLength(64)
param environmentName string

@description('Primary location for all resources')
@minLength(1)
param location string

@description('Id of the user or app to assign application roles')
param principalId string

var _fxv_0 = {
  analysisServicesServers: 'as'
  apiManagementService: 'apim-'
  appConfigurationStores: 'appcs-'
  appManagedEnvironments: 'cae-'
  appContainerApps: 'ca-'
  authorizationPolicyDefinitions: 'policy-'
  automationAutomationAccounts: 'aa-'
  blueprintBlueprints: 'bp-'
  blueprintBlueprintsArtifacts: 'bpa-'
  cacheRedis: 'redis-'
  cdnProfiles: 'cdnp-'
  cdnProfilesEndpoints: 'cdne-'
  cognitiveServicesAccounts: 'cog-'
  cognitiveServicesFormRecognizer: 'cog-fr-'
  cognitiveServicesTextAnalytics: 'cog-ta-'
  computeAvailabilitySets: 'avail-'
  computeCloudServices: 'cld-'
  computeDiskEncryptionSets: 'des'
  computeDisks: 'disk'
  computeDisksOs: 'osdisk'
  computeGalleries: 'gal'
  computeSnapshots: 'snap-'
  computeVirtualMachines: 'vm'
  computeVirtualMachineScaleSets: 'vmss-'
  containerInstanceContainerGroups: 'ci'
  containerRegistryRegistries: 'cr'
  containerServiceManagedClusters: 'aks-'
  databricksWorkspaces: 'dbw-'
  dataFactoryFactories: 'adf-'
  dataLakeAnalyticsAccounts: 'dla'
  dataLakeStoreAccounts: 'dls'
  dataMigrationServices: 'dms-'
  dBforMySQLServers: 'mysql-'
  dBforPostgreSQLServers: 'psql-'
  devicesIotHubs: 'iot-'
  devicesProvisioningServices: 'provs-'
  devicesProvisioningServicesCertificates: 'pcert-'
  documentDBDatabaseAccounts: 'cosmos-'
  eventGridDomains: 'evgd-'
  eventGridDomainsTopics: 'evgt-'
  eventGridEventSubscriptions: 'evgs-'
  eventHubNamespaces: 'evhns-'
  eventHubNamespacesEventHubs: 'evh-'
  hdInsightClustersHadoop: 'hadoop-'
  hdInsightClustersHbase: 'hbase-'
  hdInsightClustersKafka: 'kafka-'
  hdInsightClustersMl: 'mls-'
  hdInsightClustersSpark: 'spark-'
  hdInsightClustersStorm: 'storm-'
  hybridComputeMachines: 'arcs-'
  insightsActionGroups: 'ag-'
  insightsComponents: 'appi-'
  keyVaultVaults: 'kv-'
  kubernetesConnectedClusters: 'arck'
  kustoClusters: 'dec'
  kustoClustersDatabases: 'dedb'
  logicIntegrationAccounts: 'ia-'
  logicWorkflows: 'logic-'
  machineLearningServicesWorkspaces: 'mlw-'
  managedIdentityUserAssignedIdentities: 'id-'
  managementManagementGroups: 'mg-'
  migrateAssessmentProjects: 'migr-'
  networkApplicationGateways: 'agw-'
  networkApplicationSecurityGroups: 'asg-'
  networkAzureFirewalls: 'afw-'
  networkBastionHosts: 'bas-'
  networkConnections: 'con-'
  networkDnsZones: 'dnsz-'
  networkExpressRouteCircuits: 'erc-'
  networkFirewallPolicies: 'afwp-'
  networkFirewallPoliciesWebApplication: 'waf'
  networkFirewallPoliciesRuleGroups: 'wafrg'
  networkFrontDoors: 'fd-'
  networkFrontdoorWebApplicationFirewallPolicies: 'fdfp-'
  networkLoadBalancersExternal: 'lbe-'
  networkLoadBalancersInternal: 'lbi-'
  networkLoadBalancersInboundNatRules: 'rule-'
  networkLocalNetworkGateways: 'lgw-'
  networkNatGateways: 'ng-'
  networkNetworkInterfaces: 'nic-'
  networkNetworkSecurityGroups: 'nsg-'
  networkNetworkSecurityGroupsSecurityRules: 'nsgsr-'
  networkNetworkWatchers: 'nw-'
  networkPrivateDnsZones: 'pdnsz-'
  networkPrivateLinkServices: 'pl-'
  networkPublicIPAddresses: 'pip-'
  networkPublicIPPrefixes: 'ippre-'
  networkRouteFilters: 'rf-'
  networkRouteTables: 'rt-'
  networkRouteTablesRoutes: 'udr-'
  networkTrafficManagerProfiles: 'traf-'
  networkVirtualNetworkGateways: 'vgw-'
  networkVirtualNetworks: 'vnet-'
  networkVirtualNetworksSubnets: 'snet-'
  networkVirtualNetworksVirtualNetworkPeerings: 'peer-'
  networkVirtualWans: 'vwan-'
  networkVpnGateways: 'vpng-'
  networkVpnGatewaysVpnConnections: 'vcn-'
  networkVpnGatewaysVpnSites: 'vst-'
  notificationHubsNamespaces: 'ntfns-'
  notificationHubsNamespacesNotificationHubs: 'ntf-'
  operationalInsightsWorkspaces: 'log-'
  portalDashboards: 'dash-'
  powerBIDedicatedCapacities: 'pbi-'
  purviewAccounts: 'pview-'
  recoveryServicesVaults: 'rsv-'
  resourcesResourceGroups: 'rg-'
  searchSearchServices: 'srch-'
  serviceBusNamespaces: 'sb-'
  serviceBusNamespacesQueues: 'sbq-'
  serviceBusNamespacesTopics: 'sbt-'
  serviceEndPointPolicies: 'se-'
  serviceFabricClusters: 'sf-'
  signalRServiceSignalR: 'sigr'
  sqlManagedInstances: 'sqlmi-'
  sqlServers: 'sql-'
  sqlServersDataWarehouse: 'sqldw-'
  sqlServersDatabases: 'sqldb-'
  sqlServersDatabasesStretch: 'sqlstrdb-'
  storageStorageAccounts: 'st'
  storageStorageAccountsVm: 'stvm'
  storSimpleManagers: 'ssimp'
  streamAnalyticsCluster: 'asa-'
  synapseWorkspaces: 'syn'
  synapseWorkspacesAnalyticsWorkspaces: 'synw'
  synapseWorkspacesSqlPoolsDedicated: 'syndp'
  synapseWorkspacesSqlPoolsSpark: 'synsp'
  timeSeriesInsightsEnvironments: 'tsi-'
  webServerFarms: 'plan-'
  webSitesAppService: 'app-'
  webSitesAppServiceEnvironment: 'ase-'
  webSitesFunctions: 'func-'
  webStaticSites: 'stapp-'
}
var tags = {
  'azd-env-name': environmentName
}
var abbrs = _fxv_0
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg_environment 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module monitoring './nested_monitoring.bicep' = {
  name: 'monitoring'
  scope: resourceGroup('rg-${environmentName}')
  params: {
    location: location
    tags: tags
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
  }
  dependsOn: [
    subscriptionResourceId('Microsoft.Resources/resourceGroups', 'rg-${environmentName}')
  ]
}

module dashboard './nested_dashboard.bicep' = {
  name: 'dashboard'
  scope: resourceGroup('rg-${environmentName}')
  params: {
    name: '${abbrs.portalDashboards}${resourceToken}'
    applicationInsightsName: reference(
      extensionResourceId(
        '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-${environmentName}',
        'Microsoft.Resources/deployments',
        'monitoring'
      ),
      '2022-09-01'
    ).outputs.applicationInsightsName.value
    location: location
    tags: tags
  }
  dependsOn: [
    extensionResourceId(
      '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-${environmentName}',
      'Microsoft.Resources/deployments',
      'monitoring'
    )
    subscriptionResourceId('Microsoft.Resources/resourceGroups', 'rg-${environmentName}')
  ]
}

module registry './nested_registry.bicep' = {
  name: 'registry'
  scope: resourceGroup('rg-${environmentName}')
  params: {
    location: location
    tags: tags
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
  }
  dependsOn: [
    subscriptionResourceId('Microsoft.Resources/resourceGroups', 'rg-${environmentName}')
  ]
}

module keyvault './nested_keyvault.bicep' = {
  name: 'keyvault'
  scope: resourceGroup('rg-${environmentName}')
  params: {
    location: location
    tags: tags
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    principalId: principalId
  }
  dependsOn: [
    subscriptionResourceId('Microsoft.Resources/resourceGroups', 'rg-${environmentName}')
  ]
}

module apps_env './nested_apps_env.bicep' = {
  name: 'apps-env'
  scope: resourceGroup('rg-${environmentName}')
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: reference(
      extensionResourceId(
        '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-${environmentName}',
        'Microsoft.Resources/deployments',
        'monitoring'
      ),
      '2022-09-01'
    ).outputs.applicationInsightsName.value
    logAnalyticsWorkspaceName: reference(
      extensionResourceId(
        '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-${environmentName}',
        'Microsoft.Resources/deployments',
        'monitoring'
      ),
      '2022-09-01'
    ).outputs.logAnalyticsWorkspaceName.value
  }
  dependsOn: [
    extensionResourceId(
      '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-${environmentName}',
      'Microsoft.Resources/deployments',
      'monitoring'
    )
    subscriptionResourceId('Microsoft.Resources/resourceGroups', 'rg-${environmentName}')
  ]
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = reference(
  extensionResourceId(
    '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-${environmentName}',
    'Microsoft.Resources/deployments',
    'registry'
  ),
  '2022-09-01'
).outputs.loginServer.value
output AZURE_KEY_VAULT_NAME string = reference(
  extensionResourceId(
    '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-${environmentName}',
    'Microsoft.Resources/deployments',
    'keyvault'
  ),
  '2022-09-01'
).outputs.name.value
output AZURE_KEY_VAULT_ENDPOINT string = reference(
  extensionResourceId(
    '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-${environmentName}',
    'Microsoft.Resources/deployments',
    'keyvault'
  ),
  '2022-09-01'
).outputs.endpoint.value
