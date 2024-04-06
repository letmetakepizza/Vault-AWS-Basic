resource "random_id" "random_digits" {
  byte_length = 2
  count       = var.instance_amount                  # Otherwise all instances would share the same randomID.
}

resource "aws_instance" "vault_host_res" {
  count                       = var.instance_amount
  ami                         = data.aws_ami.ubuntu_west2.id
  instance_type               = var.freetier_instance_type
  key_name                    = "sshkey"
  vpc_security_group_ids      = [aws_security_group.vault_sg.id]
  subnet_id                   = aws_subnet.vault_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "VaultNode-${random_id.random_digits[count.index].dec}"
  }
}

resource "local_file" "vault_config" {
  count = var.instance_amount
  content = templatefile("./templates/vault.hcl.tpl", {
    node_index          = count.index
    instance_public_ip  = aws_instance.vault_host_res[count.index].public_ip
    instance_private_ip = aws_instance.vault_host_res[count.index].private_ip
    node1               = aws_instance.vault_host_res[0].private_ip
    node2               = aws_instance.vault_host_res[1].private_ip
    node3               = aws_instance.vault_host_res[2].private_ip
  })
  filename = "../AnsibleCode/vault-config-${count.index + 1}.hcl" #
}

resource "local_file" "ansible_inventory_yaml" {
  content = yamlencode({
    all = {
      children = {
        vault = {
          hosts = {
            for index, ip in aws_instance.vault_host_res.*.public_ip : "vault${index + 1}" => { # Simple Dynamic Inventory for Ansible
              ansible_host                 = ip
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = pathexpand("~/.ssh/sshkey.pem")                    # pathexpand replaces ~ with $HOME
              vault_config_file            = "vault-config-${index + 1}.hcl"                    # crucial for Ansible
            }
          }
        }
      }
    }
  })
  filename = "../AnsibleCode/hosts.yml"
}

resource "local_file" "ansible_cfg" {
  count    = 1
  content  = file("./templates/ansible.cfg.tpl")
  filename = "../AnsibleCode/ansible.cfg"
}

resource "local_file" "vault_systemd_file" {
  count    = 1
  content  = file("./templates/vault.service.tpl")
  filename = "../AnsibleCode/vault.service"
}



