Nautobot Deployment
===========================

Collection of files to deploy Nautobot on a single K3s linux node (tested on Debian).

This will deploy Nautobot on K3s with:
  - Persitent Storage (you will need an available Persistent Volume of 8GB or more otherwise AWX deployment will fail).
  - Nautobot Ingress on the subdomain of your choice.
  - Auto assigned SSL certificate (via Cert-Manager).

Nautobot Project:
------------------------

The Nautobot project is pulled from the [nautobot/helm-charts](https://github.com/nautobot/helm-charts) github helm repository.

You can find more information on their website [https://www.networktocode.com/nautobot](https://www.networktocode.com/nautobot) or in the repository linked above.

Nautobot Deployment Variables:
------------------------

```yml
#NAUTO_NAMESPACE='' #This is the namespace that Nautobot will be deployed to.
#NAUTO_SUBDOMAIN='' #This is the subdomain that will be used to serve your Nautobot dashboard.
#NAUTO_SQL_PW='' #this is the paasword that the Nautobot postgres user will have.
#NAUTO_REDIS_PW='' #this is the paasword that the Nautobot redis will have.
#NAUTO_RELEASE_NAME='' #this is the release name Nautobot will have. Commonly just 'nautobot'.
#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
```

  Variables can be provided 3 ways:

    1. Exporting the variable by executing a command similar to this: export domain='example.com'
    2. Running the deploy-k3s.sh script, and providing variables as prompted.
    3. Editing the deploy-k3s.sh script, uncommenting and populating the variables at the very top of the script.

Nautobot Deployment Instructions:
----------------------------

  To deploy Nautobot on K3s from this repository:

    1. apt install git --yes
    2. git clone https://github.com/autothis/k3s-deployment.git
    3. cd k3s-deployment/addons/nautobot
    4. apply your specific Nautobot deployment variables as per the instructions above.
    5. chmod +x deploy-nautobot.sh
    6. ./deploy-nautobot.sh
    
    NOTE: These instructions assume you have deployed K3s using the 'deploy-k3s.sh' script from this repository.

