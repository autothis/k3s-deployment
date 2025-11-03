[k3s-deployment](https://github.com/autothis/k3s-deployment)
===========================

Collection of files to deploy K3s on a single linux node (tested on Debian).

This will deploy K3s with:
  - Traefik disabled
  - NGINX Ingress installed and configured (the one provided by NGINX not Kubernetes)
  - Kubernetes Dashboard (including user, user role, and ingress)
  - Persistent Volumes
  - Cert-Manager installed and configured for use with Cloudflare & Self Signed Certificates

K3s Deployment Variables:
------------------------

```yml
  K3S_PERSISTENT_VOLUME_DISK='/dev/sdb'      #This is the disk you will be assigning Persistent Volumes to K3s from.
  NUMBER_PERSISTENT_VOLUMES=4      #This is the amount of persistent volumes to be created.
  DASHBOARD_SUBDOMAIN='k3s'      #This is the subdomain that will be used to serve your Kubernetes Dashboard.
  INGRESS_CONTROLLER_NAMESPACE='kubernetes-ingress'      #This is the namespace that the NGINX ingress will be deployed to.
  INGRESS_CONTROLLER_NAME='primary'     #This is the name prepended to the nginx-ingress pod name.
  DOMAIN='example.com'      #This is the domain that your services will be available on.
  CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Kubernetes Dashboard e.g. 'prod-issuer' or 'selfsigned-issuer'"
  CLOUDFLARE_API_TOKEN='ZN0tr3AL9sEHl19yqjHzpy_fAkET0keNn_ddqg_y'      #This is the cloudflare token to be used by cert-manager (only required for 'prod-issuer')
  CLOUDFLARE_EMAIL_ADDRESS='example@example.com'     #This is the email address that will be associated with your LetsEncrypt certificates  (only required for 'prod-issuer')
  
```

  Variables can be provided 3 ways:

    1. Exporting the variable by executing a command similar to this: export K3S_PERSISTENT_VOLUME_DISK='/dev/sdb'
    2. Running the deploy-k3s.sh script, and providing variables as prompted.
    3. Editing the deploy-k3s.sh script, uncommenting and populating the variables at the very top of the script.

  Important Notes:
  
    You have two options for Certificate Provisioning:
      'selfsigned-issuer' - This will deploy a root CA, and a Certificate Provisioner that uses it.
      'prod-issuer' - This will deploy a root CA, and a Certificate Provisioner that uses it.
                      This method will also deploy a Certificate Provisioner that uses LetsEncrypt for certificates,
                      and Cloudflare DNS for domain verification.
    
    When configuring the Certificate Provider, the selfsigned provider is deployed no matter which option you pick.
    The cloudflare certificate provider is only deployed, if you select 'prod-issuer'.

    If you select 'selfsigned-issuer', you do NOT need to provide any of the Cloudflare variables.

Deployment Instructions:
------------------------

  To deploy K3s on a single node from this repository:

    1. apt install git --yes
    2. git clone https://github.com/autothis/k3s-deployment.git
    3. cd k3s-deployment
    4. apply your specific K3s deployment variables as per the instructions above
       (or you can just enter the variables when prompted by the script)
    5. chmod +x deploy-k3s.sh
    6. ./deploy-k3s.sh
    7. source /etc/profile

Aliased Commands:
-----------------

  These Aliases are only applied to the host that the deploy script is run on.

  - Alias 'admin' command to easily create a token to authenticate with the Kubernetes Dashboard.
  - Alias 'k' command as an alternative to typing 'kubectl' all the time.
  - Alias 'kn' command as an alternative to typing 'kubectl get nodes -o wide' all the time (Gets K3s Nodes).
  - Alias 'kns' command as an alternative to typing 'kubectl get namespace' all the time (Gets list of Kubernetes Namespaces).
  - Alias 'kga' command as a shortcut to get all resources in a namespace.
  - Alias 'kp' command as an alternative to typing 'kubectl get pods' all the time (Gets Pods in the current Namespace). 
  - Alias 'kpa' command as an alternative to typing 'kubectl get pods -A' all the time (Gets Pods in all Namespaces). 
  - Alias 'kl' command as an alternative to typing 'kubectl logs -f' all the time (Get logs and follow).
  - Alias 'kc' command as an alternative to typing 'kubectl get certs' all the time (Get Certificates in the current Namespace).
  - Alias 'kca' command as an alternative to typing 'kubectl get certs -A' all the time (Get Certificates in all Namespaces).
  - Alias 'ki' command as an alternative to typing 'kubectl get ingress' all the time (Get Ingress in the current Namespace).
  - Alias 'kia' command as an alternative to typing 'kubectl get ingress -A' all the time (Get Ingress in all Namespaces).
  - Alias 'ks' command as an alternative to typing 'kubectl get service' all the time (Get Services in the current Namespacec).
  - Alias 'ksa' command as an alternative to typing 'kubectl get service -A' all the time (Get Services in all Namespaces).
  - Alias 'kd' command as an alternative to typing 'kubectl get deployments' all the time (Get Deployments in the current Namespace).
  - Alias 'kda' command as an alternative to typing 'kubectl get deployments -A' all the time (Get Deployments in all Namespaces).

Available Addons:
-----------------

  See [addons](https://github.com/autothis/k3s-deployment/tree/main/addons) directory for installation instructions.
  
   - [Ansible AWX](https://k3s.autothis.org/addons/awx/): Open source web UI and API to manage Ansible Playbooks, Inventories, Ansible Vault, and Credentials.
   - [Nautobot](https://k3s.autothis.org/addons/nautobot): Nautobot is an extensible and flexible Network Source of Truth and Network Automation Platform that is the cornerstone of any network automation architecture.
   - [Kube-Prometheus-Stack](https://k3s.autothis.org/addons/kube-prometheus-stack): Collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.