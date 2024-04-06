# Infrastructure As Code: Terraform and Ansible for HashiCorp Vault on AWS

This project aims to simplify the process of deploying a HashiCorp Vault cluster in AWS using Terraform and Ansible. The goal is to achieve a minimal manual intervention setup where `terraform apply -auto-approve` and `ansible-playbook playbook -i hosts.txt` are the ONLY commands needed to get the cluster up and running.

## Note: Auto_unseal and TLS configuration are not included yet.

## Goals

- **Automate Deployment**: Simplify the process of deploying a HashiCorp Vault cluster in AWS.
- **Dynamic Configuration**: Automate the creation of individual Vault configuration files and distribute them with Ansible.
- **Dynamic Inventory**: Use Terraform to generate an inventory file for Ansible.

## Key Mechanisms

### Terraform for Infrastructure and Dynamic Configuration

- **Infrastructure Creation**: Terraform is used initially to provision a cluster of three instances in AWS, setting the foundation for the Vault cluster.
- **Dynamic Inventory Creation**: Use the `yamlencode` function to dynamically create an Ansible inventory file, mapping each Vault node with its IP address.
- **Vault Configuration Files**: Generates a custom `vault.hcl` configuration file for each node.
- **Static Files**: Produces important static files like `vault.service` for systemd management and `ansible.cfg` to standardize Ansible's execution.

### Ansible for Configuration Management

- **Configuration Management**: Distributes the correct `vault.hcl` file to each node using the dynamic inventory, ensuring correct and unique configuration.
- **Vault Installation and Setup**: Handles the Vault installation through a binary file, sets up necessary configurations including user, group, and directories, and distributes each node's specific config file.

### Special Variables and Key Solutions

- **Special Variable**: The `vault_config_file` variable is crucial as it specifies the configuration file for each node. It must be included in the Ansible inventory to allow correct file distribution:

    ```yaml
    vault_config_file = "vault-config-${index + 1}.hcl"
    ```

- **Dynamic Inventory Script**: This part of the Terraform code shows how the dynamic inventory is made:
    ```hcl
    resource "local_file" "ansible_inventory_yaml" {
      content = yamlencode({
        all = {
          children = {
            vault = {
              hosts = {
                for index, ip in aws_instance.vault_host_res.*.public_ip : "vault${index + 1}" => {
                  ansible_host                 = ip
                  ansible_user                 = "ubuntu"
                  ansible_ssh_private_key_file = pathexpand("~/.ssh/sshkey.pem")
                  vault_config_file            = "vault-config-${index + 1}.hcl"
                }
              }
            }
          }
        }
      })
      filename = "../AnsibleCode/hosts.yml"
    }
    ```
