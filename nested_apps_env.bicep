param name string
param location string = resourceGroup().location
param tags object = {}
param logAnalyticsWorkspaceName string
param applicationInsightsName string = ''

resource name_resource 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(
          resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName),
          '2022-10-01'
        ).customerId
        sharedKey: listKeys(
          resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName),
          '2022-10-01'
        ).primarySharedKey
      }
    }
    daprAIConnectionString: reference(
      resourceId('Microsoft.Insights/components', applicationInsightsName),
      '2020-02-02'
    ).ConnectionString
  }
}

output name string = name
output domain string = reference(name_resource.id, '2022-10-01').defaultDomain
