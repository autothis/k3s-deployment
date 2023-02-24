Kubernetes-Dashboard Deployment
=======================

Collection of files to deploy Kubernetes-Dashboard on a single K3s linux node (tested on Debian).

This will deploy Kubernetes-Dashboard on K3s with:
  - Admin user role configured.
  - Admin user configured.
  - Kubernetes-Dashboard Ingress via HTTPS with an automatically created and managed SSL certificate (either a self signed certificate, or one signed by Lets Encrypt, depnding on which issuer variable you define).

Kubernetes-Dashboard Deployment Variables:
----------------------------------

```yml
  DASHBOARD_SUBDOMAIN='k3s'      #This is the subdomain that will be used to serve your Kubernetes Dashboard.
  DOMAIN='example.com'      #This is the domain that your services will be available on.
  CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Kubernetes Dashboard e.g. 'prod-issuer' or 'selfsigned-issuer'"
```

  Variables are provided as part of the 'deploy-k3s.sh' script included in the top level directory of this repository - See the [README.md](https://k3s.autothis.org/) file for more information.

Kubernetes-Dashboard Deployment Instructions:
-------------------------------------

  Deployment instructions are provided as part of the 'deploy-k3s.sh' script included in the top level directory of this repository - See the [README.md](https://k3s.autothis.org/) file for more information.
