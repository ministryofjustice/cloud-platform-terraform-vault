

injector:
  # True if you want to enable vault agent injection.
  enabled: true
  resources: {}
  # resources:
  #   requests:
  #     memory: 256Mi
  #     cpu: 250m
  #   limits:
  #     memory: 256Mi
  #     cpu: 250m

server:
  # Resource requests, limits, etc. for the server cluster placement. This
  # should map directly to the value of the resources field for a PodSpec.
  # By default no direct resource request is made.

 
  resources:
  # resources:
  #   requests:
  #     memory: 256Mi
  #     cpu: 250m
  #   limits:
  #     memory: 256Mi
  #     cpu: 250m

  # Ingress allows ingress services to be created to allow external access
  # from Kubernetes to access Vault pods.
  ingress:
    enabled: true
    labels: {}
      # traffic: external
    annotations:
      # |
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
    hosts:
      - host: vault.apps.imran-v.cloud-platform.service.justice.gov.uk
        paths: []

    tls:
      - secretName: vault-tls
        hosts:
          - vault.apps.imran-v.cloud-platform.service.justice.gov.uk


  # Used to define custom readinessProbe settings
  readinessProbe:
    enabled: false
    # If you need to use a http path instead of the default exec
    # path: /v1/sys/health?standbyok=true
  # Used to enable a livenessProbe for the pods
  livenessProbe:
    enabled: false
    path: "/v1/sys/health?standbyok=true"
    initialDelaySeconds: 60

  # This configures the Vault Statefulset to create a PVC for data
  # storage when using the file or raft backend storage engines.
  # See https://www.vaultproject.io/docs/configuration/storage/index.html to know more
  dataStorage:
    enabled: true
    # Size of the PVC created
    size: 10Gi
    # Name of the storage class to use.  If null it will use the
    # configured default Storage Class.
    storageClass: null
    # Access Mode of the storage device being used for the PVC
    accessMode: ReadWriteOnce

  # This configures the Vault Statefulset to create a PVC for audit
  # logs.  Once Vault is deployed, initialized and unseal, Vault must
  # be configured to use this for audit logs.  This will be mounted to
  # /vault/audit
  # See https://www.vaultproject.io/docs/audit/index.html to know more
  auditStorage:
    enabled: false
    # Size of the PVC created
    size: 10Gi
    # Name of the storage class to use.  If null it will use the
    # configured default Storage Class.
    storageClass: null
    # Access Mode of the storage device being used for the PVC
    accessMode: ReadWriteOnce

  # Run Vault in "dev" mode. This requires no further setup, no state management,
  # and no initialization. This is useful for experimenting with Vault without
  # needing to unseal, store keys, et. al. All data is lost on restart - do not
  # use dev mode for anything other than experimenting.
  # See https://www.vaultproject.io/docs/concepts/dev-server.html to know more
  dev:
    enabled: false
