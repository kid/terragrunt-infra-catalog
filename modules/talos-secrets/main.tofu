provider "onepassword" {
  account = var.op_account
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = var.talos_endpoints
  nodes                = var.talos_nodes
}

locals {
  secrets = {
    MACHINE_TOKEN  = talos_machine_secrets.this.machine_secrets.trustdinfo.token
    MACHINE_CA_CRT = talos_machine_secrets.this.machine_secrets.certs.os.cert
    MACHINE_CA_KEY = talos_machine_secrets.this.machine_secrets.certs.os.key

    CLUSTER_ID                        = talos_machine_secrets.this.machine_secrets.cluster.id
    CLUSTER_SECRET                    = talos_machine_secrets.this.machine_secrets.cluster.secret
    CLUSTER_TOKEN                     = talos_machine_secrets.this.machine_secrets.secrets.bootstrap_token
    CLUSTER_SECRETBOXENCRYPTIONSECRET = talos_machine_secrets.this.machine_secrets.secrets.secretbox_encryption_secret

    CLUSTER_CA_CRT = talos_machine_secrets.this.machine_secrets.certs.k8s.cert
    CLUSTER_CA_KEY = talos_machine_secrets.this.machine_secrets.certs.k8s.key

    CLUSTER_AGGREGATORCA_CRT = talos_machine_secrets.this.machine_secrets.certs.k8s_aggregator.cert
    CLUSTER_AGGREGATORCA_KEY = talos_machine_secrets.this.machine_secrets.certs.k8s_aggregator.key

    CLUSTER_SERVICEACCOUNT_KEY = talos_machine_secrets.this.machine_secrets.certs.k8s_serviceaccount.key

    CLUSTER_ETCD_CA_CRT = talos_machine_secrets.this.machine_secrets.certs.etcd.cert
    CLUSTER_ETCD_CA_KEY = talos_machine_secrets.this.machine_secrets.certs.etcd.key
  }
}

resource "onepassword_item" "talos" {
  vault    = var.op_vault
  title    = var.op_item
  category = "password"

  section_map = {
    "Talos" = {
      field_map = {
        for key, value in local.secrets : key => {
          type  = "CONCEALED"
          value = value
        }
      }
    }
  }
}
