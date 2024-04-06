# HashiCorp Vault Setup

**Quick Summary:** Ensure you set the `vault_config_file` parameter in your inventory for proper integration with Terraform.

This role installs HashiCorp Vault from a binary file.

## Requirements

Before deploying this Ansible role, make sure the `vault_config_file` variable is defined in your inventory. This is essential for the integration with Terraform, which dynamically generates an inventory and assigns a unique Vault configuration file to each host:

**Important:**
The `vault_config_file` parameter is a **REQUIRED** parameter for the inventory file, as demonstrated below in the Terraform script located at `TerraformCode/main.yml` (line 60+):

```hcl
resource "local_file" "ansible_inventory_yaml" {
  content = yamlencode({
    all = {
      children = {
        vault = {
          hosts = {
            "vault1" => {
              ansible_host = "x.x.x.x",
              vault_config_file = "vault-config-${index + 1}.hcl"   // REQUIRED PARAMETER
            },
            // something else...
          }
        }
      }
    }
  })
  filename = "path/to/hosts.yml"
}
