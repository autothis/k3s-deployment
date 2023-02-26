Hashicorp Vault Deployment
===========================

Collection of files to deploy Hashicorp Vault on a single K3s linux node (tested on Debian).

This will deploy Hashicorp Vault on K3s with:
  - Persitent Storage for Vault Data.
  - Hashicorp Vault Ingress on the subdomain of your choice.
  - Auto assigned SSL certificate (via Cert-Manager).

Hashicorp Vault Project:
------------------------

The Hashicorp Vault is pulled from the [hashicorp/vault-helm](https://github.com/hashicorp/vault-helm) github helm repository.

You can find more information on their website [https://www.vaultproject.io](https://www.vaultproject.io) or in the repository linked above.

Hashicorp Vault Deployment Variables:
------------------------

```yml
#HASHICORP_VAULT_NAMESPACE='' #This is the namespace that Hashicorp Vault will be deployed to e.g. 'hashicorp-vault'.
#HASHICORP_VAULT_SUBDOMAIN='' #This is the subdomain that will be used to serve your Hashicorp Vault web UI e.g. 'vault'.
#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
#CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Hashicorp Vault e.g. 'prod-issuer' or 'selfsigned-issuer'.
```

  Variables can be provided 3 ways:

    1. Exporting the variable by executing a command similar to this: export DOMAIN='example.com'
    2. Running the deploy-k3s.sh script, and providing variables as prompted.
    3. Editing the deploy-k3s.sh script, uncommenting and populating the variables at the very top of the script.

Hashicorp Vault Deployment Instructions:
----------------------------

  To deploy Hashicorp Vault on K3s from this repository:

    1. apt install git --yes
    2. git clone https://github.com/autothis/k3s-deployment.git
    3. cd k3s-deployment/addons/hashicorp-vault
    4. apply your specific Hashicorp Vault deployment variables as per the instructions above.
    5. chmod +x deploy-hashicorp-vault.sh
    6. ./deploy-kube-hashicorp-vault.sh
    
    NOTE: These instructions assume you have deployed K3s using the 'deploy-k3s.sh' script from this repository.
