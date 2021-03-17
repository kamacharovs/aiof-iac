output "application_insights_instrumentation_key" {
  description = "Application insights instrumentation key"
  value       = azurerm_application_insights.heimdall.instrumentation_key
}