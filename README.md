k3s-deployment
===========================

Collection of files to deploy K3s on a single linux node (tested on Debian).
This will deploy K3s with:
  - Treafik disabled
  - NGINX Ingress installed and configured (the one provided by NGINX not Kubernetes)
  - Kubernetes Dashboard (including user, user role, and ingress)
  - Persistent Volumes
  - Cert-Manager installed and configured for use with Cloudflare.

K3s Deployment Variables:
------------------------

```yml
  k3dsk='/dev/sdb'      #This is the disk you will be assigning Persistent Volumes to K3s from.
  diskno=4      #This is the amount of persistent volumes to be created.
  ingns='kubernetes-ingress'      #This is the namespace that the NGINX ingress will be deployed to.
  ingname='primary'     #This is the name prepended to the nginx-ingress pod name.
  cftoken='ZN0tr3AL9sEHl19yqjHzpy_fAkET0keNn_ddqg_y'      #This is the cloudflare token to be used by cert-manager.
  cfemail='example@example.com'     #This is the email address that will be associated with your LetsEncrypt certificates.
  domain='example.com'      #This is the domain that your services will be available on.
```

  Variables can be provided 3 ways:

    1. Exporting the variable by executing a command similar to this: export k3dsk='/dev/sdb'
    2. Running the deploy-k3s.sh script, and providing variables as prompted.
    3. Editing the deploy-k3s.sh script, uncommenting and populating the variables at the very top of the script.

Deployment Instructions:
------------------------

  To deploy K3s on a single node from this repository:

    1. apt install git --yes
    2. git clone https://github.com/autothis/k3s-deployment.git
    3. cd k3s-deployment
    4. apply your specific K3s deployment variables as per the instructions above.
    5. chmod +x deploy-k3s.sh
    6. ./deploy-k3s.sh
