AWX Deployment
===========================

Collection of files to deploy AWX on a single K3s linux node (tested on Debian).
This will deploy AWX on K3s with:
  - Persitent Storage (you will need an available Persistent Volume of 8GB or more otherwise AWX deployment will fail).
  - AWX Ingress on the subdomain of your choice.
  - Auto assigned SSL certificate (via Cert-Manager).

AWX Deployment Variables:
------------------------

```yml
  #AWX_NAMESPACE='' #This is the namespace that AWX will be deployed to.
	#AWX_VERSION='' #This is the version of AWX to be deployed, this variable will automatically populated.
	#AWX_SUBDOMAIN='' #This is the subdomain that will be used to serve your AWX dashboard.
	#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.

```

  Variables can be provided 3 ways:

    1. Exporting the variable by executing a command similar to this: export DOMAIN='example.com'
    2. Running the deploy-k3s.sh script, and providing variables as prompted.
    3. Editing the deploy-k3s.sh script, uncommenting and populating the variables at the very top of the script.

AWX Deployment Instructions:
----------------------------

  To deploy AWX on K3s from this repository:

    1. apt install git --yes
    2. git clone https://github.com/autothis/k3s-deployment.git
    3. cd k3s-deployment/addons/awx
    4. apply your specific AWX deployment variables as per the instructions above.
    5. chmod +x deploy-awx.sh
    6. ./deploy-awx.sh
    
    NOTE: These instructions assume you have deployed K3s using the 'deploy-k3s.sh' script from this repository.

AWX Update Instructions:
------------------------

  To deploy AWX on K3s from this repository:

    1. Backup your AWX data
    2. cd k3s-deployment/addons/awx
    3. chmod +x update-awx.sh
    4. ./update-awx.sh
    
    NOTE: These instructions assume you have deployed K3s and AWX using the 'deploy-k3s.sh' and 'deploy-awx.sh' script from this repository.
