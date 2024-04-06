hashicorp_vault_setup
=========
**Quick Summary:** Just set `vault_config_file` param in your inventory.
**Quick Summary:** Just set `vault_config_file` param in your inventory.
**Quick Summary:** Just set `vault_config_file` param in your inventory.


Role will install HashiCorp Vault by binary file. 

Requirements.
------------

!Before deploying this Ansible role, ensure the `vault_config_file` variable is defined in your inventory, crucial for Terraform integration. The Terraform script dynamically generates an inventory, assigning each host a unique Vault configuration file:

!BECAUSE:
TerraformCode/main.yml/ (string 60+):

resource "local_file" "ansible_inventory_yaml" {
  content = yamlencode({
    all = {
      children = {
        vault = {
          hosts = {
            "vault1" => {
              ansible_host = "x.x.x.x"
              vault_config_file = "vault-config-${index + 1}.hcl"   # REQUIRED PARAMETER FOR THE inventory file
            },
            ...
          }
        }
      }
    }
  })
  filename = "path/to/hosts.yml"
}


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: vault
      become: true
      roles:
         - hashicorp_vault_install