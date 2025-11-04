variable "vnets" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    address_space       = list(string)
    tags = optional(map(string))
    ip_address_pool = optional(list(object({
      id                     = string
      number_of_ip_addresses = string
    })), [])

    # Optional simple fields
    bgp_community                 = optional(string)
    dns_servers                   = optional(list(string))
    edge_zone                     = optional(string)
    flow_timeout_in_minutes       = optional(number)
    private_endpoint_vnet_policies = optional(string)

    # Optional DDoS Protection Plan
    ddos_protection_plan = optional(object({
      id     = string
      enable = bool
    }))

    # Optional Encryption
    encryption = optional(object({
      enforcement = string
    }))

    # Optional Subnets
    subnet = optional(list(object({
      subnet_name                                 = string
      address_prefixes                            = list(string)
      security_group                              = optional(string)
      default_outbound_access_enabled             = optional(bool)
      private_endpoint_network_policies           = optional(string)
      private_link_service_network_policies_enabled = optional(bool)
      route_table_id                              = optional(string)
      service_endpoints                           = optional(list(string))
      service_endpoint_policy_ids                 = optional(list(string))

      # Optional delegation block
      delegation = optional(list(object({
        name = string

        service_delegation = optional(object({
          name    = string
          actions = optional(list(string))
        }))
      })))
    })))
  }))
}