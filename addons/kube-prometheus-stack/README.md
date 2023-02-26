Kube Prometheus Stack Deployment
===========================

Collection of files to deploy Kube Prometheus Stack on a single K3s linux node (tested on Debian).

This will deploy Kube Prometheus Stack on K3s with:
  - Persitent Storage for Alert Manager and Prometheus (not yet Grafana).
  - Kube Prometheus Stack Dashboard (Grafana) Ingress on the subdomain of your choice.
  - Auto assigned SSL certificate (via Cert-Manager).

Kube Prometheus Stack Project:
------------------------

The Kube Prometheus Stack is pulled from the [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) github repository.

You can find more information on their website https://prometheus-operator.dev or in the github repository linked above.

Kube Prometheus Stack Deployment Variables:
------------------------

```yml
#KUBE_PROMETHEUS_STACK_NAMESPACE='' #This is the namespace that Kube Prometheus Stack will be deployed to e.g. 'monitoring'.
#KUBE_PROMETHEUS_STACK_SUBDOMAIN='' #This is the subdomain that will be used to serve your Kube Prometheus Stack dashboard e.g. 'kubemonitor'.
#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
#CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Kube Prometheus Stack e.g. 'prod-issuer' or 'selfsigned-issuer'.
```

  Variables can be provided 3 ways:

    1. Exporting the variable by executing a command similar to this: export DOMAIN='example.com'
    2. Running the deploy-k3s.sh script, and providing variables as prompted.
    3. Editing the deploy-k3s.sh script, uncommenting and populating the variables at the very top of the script.

Kube Prometheus Stack Deployment Instructions:
----------------------------

  To deploy AWX on K3s from this repository:

    1. apt install git --yes
    2. git clone https://github.com/autothis/k3s-deployment.git
    3. cd k3s-deployment/addons/kube-prometheus-stack
    4. apply your specific AWX deployment variables as per the instructions above.
    5. chmod +x deploy-kube-prometheus-stack.sh
    6. ./deploy-kube-prometheus-stack.sh
    
    NOTE: These instructions assume you have deployed K3s using the 'deploy-k3s.sh' script from this repository.