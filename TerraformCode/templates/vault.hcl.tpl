storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault_node-${node_index + 1}"

  retry_join {
    leader_api_addr = "${node1}"
  }
  retry_join {
    leader_api_addr = "${node2}"
  }
  retry_join {
    leader_api_addr = "${node3}"
  }
}

listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable = 1
}
api_addr = "http://${instance_public_ip}:8200"
cluster_addr = "http://${instance_private_ip}:8201"
cluster_name = "vault-gde-bruh"
ui = true
log_level = "trace"
disable_mlock = true
