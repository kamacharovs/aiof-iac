/*
 * Application Insights
 */
resource "azurerm_application_insights" "heimdall" {
  name                = "heimdall-${var.env}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  application_type    = var.ai_application_type
}

resource "azurerm_application_insights_web_test" "heimdall_aiof_auth_health" {
  name                    = "aiof-auth-health"
  location                = var.rg.location
  resource_group_name     = var.rg.name
  application_insights_id = azurerm_application_insights.heimdall.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 120
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "us-tx-sn1-azr", "us-il-ch1-azr", "us-va-ash-azr", "us-fl-mia-edge"]

  configuration = <<XML
  <WebTest Name="aiof-auth-health" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
    <Items>
      <Request Method="GET" Version="1.1" Url="https://${var.aiof_auth_hostname}/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False"/>
    </Items>
  </WebTest>
  XML
}

resource "azurerm_application_insights_web_test" "heimdall_aiof_api_health" {
  name                    = "aiof-api-health"
  location                = var.rg.location
  resource_group_name     = var.rg.name
  application_insights_id = azurerm_application_insights.heimdall.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 120
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "us-tx-sn1-azr", "us-il-ch1-azr", "us-va-ash-azr", "us-fl-mia-edge"]

  configuration = <<XML
  <WebTest Name="aiof-auth-health" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
    <Items>
      <Request Method="GET" Version="1.1" Url="https://${var.aiof_api_hostname}/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False"/>
    </Items>
  </WebTest>
  XML
}

resource "azurerm_application_insights_web_test" "heimdall_aiof_metadata_health" {
  name                    = "aiof-metadata-health"
  location                = var.rg.location
  resource_group_name     = var.rg.name
  application_insights_id = azurerm_application_insights.heimdall.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 120
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "us-tx-sn1-azr", "us-il-ch1-azr", "us-va-ash-azr", "us-fl-mia-edge"]

  configuration = <<XML
  <WebTest Name="aiof-metadata-health" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
    <Items>
      <Request Method="GET" Version="1.1" Url="https://${var.aiof_metadata_hostname}/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False"/>
    </Items>
  </WebTest>
  XML
}