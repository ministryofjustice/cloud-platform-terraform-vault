global:
  enabled: true
  tlsDisable: true
injector:
  replicas: 2
  metrics:
    enabled: true
server:
  standalone:
    enabled: false
  ha:
    enabled: true
    replicas: 2
    config: |
      ui = true
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "dynamodb" {
        ha_enabled = "true"
        region     = "eu-west-1"
        table      = "${dynamo_table}"
        access_key = "${dynamo_access_key}"
        secret_key = "${dynamo_secret_key}"
      }
      seal "awskms" {
        region     = "eu-west-1"
        access_key = "${seal_access_key}"
        secret_key = "${seal_secret_key}"
        kms_key_id = "${seal_kms}"
      }
      service_registration "kubernetes" {}
    disruptionBudget:
      maxUnavailable: 1
  dataStorage:
    enabled: false
ui:
  enabled: true
  activeVaultPodOnly: false
  serviceType: "NodePort"
  serviceNodePort: null
  externalPort: 8200
