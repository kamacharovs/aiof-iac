output "emitter_hostname" {
  value       = azurerm_function_app.eventing_emitter_fa.default_hostname
  description = "Emitter hostname"
}

output "emitter_function_key" {
  value       = data.azurerm_function_app_host_keys.eventing_emitter_fa_host_keys.master_key
  description = "Emitter function key"
}