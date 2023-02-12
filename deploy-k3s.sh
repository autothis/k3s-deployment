#!/bin/bash

# Define variables for K3s deployment (uncomment lines, and populate variables - not required if using other methods of variables population).

#K3S_PERSISTENT_VOLUME_DISK='' #This is the disk you will be assigning Persistent Volumes to K3s from.
#NUMBER_PERSISTENT_VOLUMES='' #This is the amount of persistent volumes to be created, keep in mind that there is no consumption controll (they share the same disk).
#DASHBOARD_SUBDOMAIN='' #This is the subdomain that will be used to serve your Kubernetes Dashboard.
#INGRESS_CONTROLLER_NAMESPACE='' #This is the namespace that the NGINX ingress will be deployed to.
#INGRESS_CONTROLLER_NAME='' #This is the name prepended to the nginx-ingress pod name.
#CLOUDFLARE_API_TOKEN='' #This is the cloudflare token to be used by cert-manager.
#CLOUDFLARE_EMAIL_ADDRESS='' #This is the email address that will be associated with your LetsEncrypt certificates e.g. 'youremailaddress@here.com'.
#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.

# Create Functions

  set_k3svariables () {

    # Define K3S_VARIABLE array containing required variables for K3s deployment
    K3S_VARIABLE_1=("K3S_PERSISTENT_VOLUME_DISK" "$K3S_PERSISTENT_VOLUME_DISK" "This is the disk you will be assigning Persistent Volumes to K3s from e.g. '/dev/sdb'")
    K3S_VARIABLE_2=("NUMBER_PERSISTENT_VOLUMES" "$NUMBER_PERSISTENT_VOLUMES" "This is the amount of persistent volumes to be created e.g. '4'")
    K3S_VARIABLE_3=("DASHBOARD_SUBDOMAIN" "$DASHBOARD_SUBDOMAIN" "This is the subdomain that will be used to serve your Kubernetes Dashboard. e.g. 'k3s' will become k3s.yourdomain.com")
    K3S_VARIABLE_4=("INGRESS_CONTROLLER_NAMESPACE" "$INGRESS_CONTROLLER_NAMESPACE" "This is the namespace that the NGINX ingress will be deployed to e.g. 'kubernetes-ingress'")
    K3S_VARIABLE_5=("INGRESS_CONTROLLER_NAME" "$INGRESS_CONTROLLER_NAME" "This is the name prepended to the nginx-ingress pod name e.g. 'primary'")
    K3S_VARIABLE_6=("CLOUDFLARE_API_TOKEN" "$CLOUDFLARE_API_TOKEN" "This is the cloudflare token to be used by cert-manager e.g. 'ZN0tr3AL9sEHl19yqjHzpy_fAkET0keNn_ddqg_y'")
    K3S_VARIABLE_7=("CLOUDFLARE_EMAIL_ADDRESS" "$CLOUDFLARE_EMAIL_ADDRESS" "This is the email address that will be associated with your LetsEncrypt certificates e.g. 'youremailaddress@here.com'")
    K3S_VARIABLE_8=("DOMAIN" "$DOMAIN" "This is the domain that your services will be available on e.g. 'yourdomain.com'")

   # Combine K3S_VARIABLE arrays int the K3S_VARIABLES array
   K3S_VARIABLES=(
     K3S_VARIABLE_1[@]
     K3S_VARIABLE_2[@]
     K3S_VARIABLE_3[@]
     K3S_VARIABLE_4[@]
     K3S_VARIABLE_5[@]
     K3S_VARIABLE_6[@]
     K3S_VARIABLE_7[@]
     K3S_VARIABLE_8[@]
   )
  }

  print_title () {

    printf ${YELLOW}"#%.0s"  $(seq 1 ${BREAK})
    printf "\n"
    printf "$TITLE \n"
    printf "#%.0s"  $(seq 1 ${BREAK})
    printf "\n"${COLOUR_OFF}
  }

# Define Output Colours

  # Reset
  COLOUR_OFF='\033[0m'       # Text Reset

  # Regular Colors
  BLACK='\033[0;30m'        # Black
  RED='\033[0;31m'          # Red
  GREEN='\033[0;32m'        # Green
  YELLOW='\033[0;33m'       # Yellow
  BLUE='\033[0;34m'         # Blue
  PURPLE='\033[0;35m'       # Purple
  CYAN='\033[0;36m'         # Cyan
  WHITE='\033[0;37m'        # White

# Get current working directory

  K3S_DEPLOY_PATH=$(pwd)

# Timeout in seconds

  TIMEOUT=300

# Break width '='

  BREAK=150

# Set K3 Variables

  set_k3svariables
  K3S_MISSING_VARIABLES=()

# Print Local Disk Table

  TITLE="Local Disk Table"
  print_title

  lsblk -f

# Missing Variables

  TITLE="Looking for missing K3s Deployment Variables"
  print_title

  # Loop K3S_VARIABLES looking for missing variables

    COUNT=${#K3S_VARIABLES[@]}
    for ((i=0; i<$COUNT; i++))
    do
      NAME=${!K3S_VARIABLES[i]:0:1}
      VALUE=${!K3S_VARIABLES[i]:1:1}
      DESC=${!K3S_VARIABLES[i]:2:1}

      if [[ -z "${VALUE}" ]]; then
        echo "Name: ${NAME}"
        printf "Value: ${RED}${NAME} is undefined\n${COLOUR_OFF}"
        echo "Description: ${DESC}"
        printf ${WHITE}"=%.0s"  $(seq 1 ${BREAK})${COLOUR_OFF}
        printf "\n${COLOUR_OFF}"
        K3S_MISSING_VARIABLES+=( "K3S_VARIABLE_$(expr $i + 1)[@]" )
      fi
    done

  # Loop K3S_MISSING_VARIABLES to give user option to define any missing variables

    COUNT=${#K3S_MISSING_VARIABLES[@]}
    for ((i=0; i<$COUNT; i++))
    do
      NAME=${!K3S_MISSING_VARIABLES[i]:0:1}
      VALUE=${!K3S_MISSING_VARIABLES[i]:1:1}
      DESC=${!K3S_MISSING_VARIABLES[i]:2:1}

      printf "${YELLOW}No value provided for '${NAME}'\n${COLOUR_OFF}"
      printf "$DESC\n"
      read -p "$(printf "${CYAN}Provide a value for '${NAME}': ${GREEN}")" $NAME
      printf "${COLOUR_OFF}"
    done

# Update K3 Variables

  set_k3svariables
  clear

# Loop K3S_VARIABLES to display variables to be used for K3s deployment.

  TITLE="Variables to be using in K3s Deployment"
  print_title

  COUNT=${#K3S_VARIABLES[@]}
  for ((i=0; i<$COUNT; i++))
  do
    NAME=${!K3S_VARIABLES[i]:0:1}
    VALUE=${!K3S_VARIABLES[i]:1:1}
    DESC=${!K3S_VARIABLES[i]:2:1}

    if [[ -z "${VALUE}" ]]; then
      echo "Name: ${NAME}"
      printf "Value: ${RED}${NAME} is undefined\n${COLOUR_OFF}"
      echo "Description: ${DESC}"
      printf ${WHITE}"=%.0s"  $(seq 1 ${BREAK})${COLOUR_OFF}
      printf "\n${COLOUR_OFF}"
    else
      printf "Name: ${CYAN}${NAME}\n${COLOUR_OFF}"
      printf "Value: ${GREEN}${VALUE}\n${COLOUR_OFF}"
      printf "Description: ${WHITE}${DESC}\n${COLOUR_OFF}"
      printf ${BLUE}"=%.0s"  $(seq 1 ${BREAK}) \n
      printf "\n${COLOUR_OFF}"
    fi
  done

# Confirm Variables before Deployment

  read -p "$(printf "${YELLOW}Would you like to proceed with deployment, based on the variables listed above? [y/N] ${COLOUR_OFF}")" -r
  if [[ $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    printf "${GREEN}Proceeding with provided variables...\n${COLOUR_OFF}"
  elif [[ $REPLY =~ ^([nN][oO]|[nN])$ ]]
  then
    printf "${RED}You have chosen not to proceed, exiting...\n${COLOUR_OFF}"
    exit
  else
    printf "${RED}You have provided an invaild answer, exiting...\n${COLOUR_OFF}"
    exit
  fi

# Install Prerequisites

  TITLE="Installing Prerequisites"
  print_title

  apt install sudo git curl gpg apt-transport-https --yes

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Install Kustomize

  TITLE="Installing Kustomize"
  print_title

  #https://github.com/kubernetes-sigs/kustomize
  cd /usr/bin
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Update Profiles

  TITLE="Updating User Profile"
  print_title

  cd $K3S_DEPLOY_PATH
  echo "alias k=kubectl" >> /etc/profile
  echo "complete -o default -F __start_kubectl k" >> /etc/profile
  echo "alias admin='kubectl -n kubernetes-dashboard create token admin-user'" >> /etc/profile
  source /etc/profile

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Disable SWAP

  TITLE="Disabling SWAP"
  print_title

  swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  echo "Dont forget to reclaim space if you want to."

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Configure Secondary Disk

  TITLE="Configuring Secondary Disk for K3s Persistent Volumes"
  print_title

  printf "o\nn\np\n1\n\n\nw\n" | sudo fdisk $K3S_PERSISTENT_VOLUME_DISK
  sudo mkfs.ext4 ${K3S_PERSISTENT_VOLUME_DISK}1
  DISK_UUID=$(blkid -s UUID -o value ${K3S_PERSISTENT_VOLUME_DISK}1)
  sudo mkdir /mnt/$DISK_UUID
  sudo mount -t ext4 ${K3S_PERSISTENT_VOLUME_DISK}1 /mnt/$DISK_UUID
  echo UUID=`sudo blkid -s UUID -o value ${K3S_PERSISTENT_VOLUME_DISK}1` /mnt/$DISK_UUID ext4 defaults 0 2 | sudo tee -a /etc/fstab

  for i in $(seq 1 $NUMBER_PERSISTENT_VOLUMES); do
    sudo mkdir -p /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i}
    sudo mount --bind /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i}
  done

  for i in $(seq 1 $NUMBER_PERSISTENT_VOLUMES); do
    echo /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i} none bind 0 0 | sudo tee -a /etc/fstab
  done

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Install K3s

  TITLE="Installing K3s (without Traefik)"
  print_title

  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -s -
  mkdir ~/.kube
  kubectl config view --raw > ~/.kube/config

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for K3s to be Ready

  TITLE="Waiting for K3s to be Ready"
  print_title

  K3S_PODS=$(kubectl get pods -n kube-system -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a K3S_PODS <<< "$K3S_PODS"

  # wait for there to be 4 pods in the kube-system namespace
  while [ ${#K3S_PODS[@]} -ne 3 ]
  do
    K3S_PODS=$(kubectl get pods -n kube-system -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a K3S_PODS <<< "$K3S_PODS"
  done

  # wait for those 4 pods to be in a ready state
  for i in "${K3S_PODS[@]}"; do
    kubectl wait -n kube-system --for=condition=Ready pod/${i} --timeout=${TIMEOUT}
  done

  # Wait for Kubernetes Health API to return 'ok' result
  END=$(($SECONDS + $TIMEOUT))
  while [ ${SECONDS} -le ${END} ]
  do
    if [[ ${K3S_STATUS} != "ok" ]]
    then
      K3S_STATUS=$(kubectl get --raw='/readyz?')
    else
      END=0
    fi
  done

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Install Helm

  TITLE="Installing Helm"
  print_title

  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
  apt update
  apt install helm --yes

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Install NGINX Ingress Controller

  TITLE="Installing NGINX Ingress Controller: ${INGRESS_CONTROLLER_NAME}-nginx-ingress in Namespace ${INGRESS_CONTROLLER_NAMESPACE}"
  print_title

  # https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
  helm repo add nginx-stable https://helm.nginx.com/stable
  helm repo update
  helm install "$INGRESS_CONTROLLER_NAME" nginx-stable/nginx-ingress --namespace "$INGRESS_CONTROLLER_NAMESPACE" --create-namespace

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for NGINX Ingresss Controller to be Ready

  TITLE="Waiting for NGINX Ingress Controller to be Ready"
  print_title

  NGINX_INGRESS_PODS=$(kubectl get pods -n ${INGRESS_CONTROLLER_NAMESPACE} -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a NGINX_INGRESS_PODS <<< "$NGINX_INGRESS_PODS"

  # wait for there to be 1 pod in the NGINX Ingress Controller namespace
  while [ ${#NGINX_INGRESS_PODS[@]} -ne 1 ]
  do
    NGINX_INGRESS_PODS=$(kubectl get pods -n ${INGRESS_CONTROLLER_NAMESPACE} -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a NGINX_INGRESS_PODS <<< "$NGINX_INGRESS_PODS"
  done

  # wait for that 1 pod to be in a ready state
  for i in "${NGINX_INGRESS_PODS[@]}"; do
    kubectl wait -n ${INGRESS_CONTROLLER_NAMESPACE} --for=condition=Ready pod/${i} --timeout=${TIMEOUT}
  done

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Install Cert Manager

  TITLE="Installing Cert Manager in Namespace cert-manager"
  print_title

  # https://www.nginx.com/blog/automating-certificate-management-in-a-kubernetes-environment/
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.9.1 --set installCRDs=true

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Cert Manager to be Ready

  TITLE="Waiting for Cert Manager to be Ready"
  print_title

  CERT_MANAGER_PODS=$(kubectl get pods -n cert-manager -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a CERT_MANAGER_PODS <<< "$CERT_MANAGER_PODS"

  # wait for there to be 3 pods in the cert-manager namespace
  while [ ${#CERT_MANAGER_PODS[@]} -ne 3 ]
  do
    CERT_MANAGER_PODS=$(kubectl get pods -n cert-manager -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a CERT_MANAGER_PODS <<< "$CERT_MANAGER_PODS"
  done

  # wait for those 3 pods to be in a ready state
  for i in "${CERT_MANAGER_PODS[@]}"; do
    kubectl wait -n cert-manager --for=condition=Ready pod/${i} --timeout=${TIMEOUT}
  done

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Update File 'cloudflare-secret.yml'

  TITLE="Updating file cloudflare-secret.yml with K3s Deployment Variables"
  print_title

  sed -i "s/CLOUDFLARE_API_TOKEN/$CLOUDFLARE_API_TOKEN/g" cert-manager/cloudflare-secret.yml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Create File 'cloudflare-dns-challenge.yml'

  TITLE="Updating file cloudflare-dns-challenge.yml with K3s Deployment Variables"
  print_title

  sed -i "s/CLOUDFLARE_EMAIL_ADDRESS/$CLOUDFLARE_EMAIL_ADDRESS/g" cert-manager/cloudflare-dns-challenge.yml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Create Cloudflare Secret and DNS Challenge

  TITLE="Creating Cloudflare Secret and DNS Challenge"
  print_title

  kubectl create -f cert-manager/cloudflare-secret.yml
  kubectl create -f cert-manager/cloudflare-dns-challenge.yml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Create File 'kubernetes-dashboard.yml'

  TITLE="Downloading file kubernetes-dashboard.yml"
  print_title

  GITHUB_URL=https://github.com/kubernetes/dashboard/releases
  VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
  curl https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml > kubernetes-dashboard/kubernetes-dashboard.yml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Create File 'dashboard-ingress.yml'

  TITLE="Updating file dashboard-ingress.yml with K3s Deployment Variables"
  print_title

  sed -i "s/DOMAIN/$DOMAIN/g" kubernetes-dashboard/dashboard-ingress.yml
  sed -i "s/DASHBOARD_SUBDOMAIN/$DASHBOARD_SUBDOMAIN/g" kubernetes-dashboard/dashboard-ingress.yml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Create Dashboard, Dashboard User Admin, Admin Role, and Dashboard Ingress

  TITLE="Creating and configuring K3s Dashboard and associated roles, users and ingress"
  print_title

  kubectl create -f kubernetes-dashboard/kubernetes-dashboard.yml
  kubectl create -f kubernetes-dashboard/dashboard-admin-user.yml -f kubernetes-dashboard/dashboard-admin-user-role.yml
  kubectl create -f kubernetes-dashboard/dashboard-ingress.yml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# ait for Kubernetes Dashboard to be Ready

  TITLE="Waiting for Kubernetes Dashboard to be Ready"
  print_title

  K3S_DASHBOARD_PODS=$(kubectl get pods -n kubernetes-dashboard -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a K3S_DASHBOARD_PODS <<< "$K3S_DASHBOARD_PODS"

  # wait for there to be 3 pods in the kubernetes-dashboard namespace
  while [ ${#K3S_DASHBOARD_PODS[@]} -ne 2 ]
  do
    K3S_DASHBOARD_PODS=$(kubectl get pods -n kubernetes-dashboard -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a K3S_DASHBOARD_PODS <<< "$K3S_DASHBOARD_PODS"
  done

  # wait for those 2 pods to be in a ready state
  for i in "${K3S_DASHBOARD_PODS[@]}"; do
    kubectl wait -n kubernetes-dashboard --for=condition=Ready pod/${i} --timeout=${TIMEOUT}
  done

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Provision Storage

  TITLE="Creating Persistent Volume Provisioner"
  print_title

  kubectl apply -f sig-storage/persistent-volume-provisioner.yml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Persistent Volumes to be Ready

  TITLE="Waiting for Persistent Volumes to be Ready"
  print_title

  K3S_PERSISTENT_VOLUMES=$(kubectl get pv -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a K3S_PERSISTENT_VOLUMES <<< "$K3S_PERSISTENT_VOLUMES"

  # wait for there to be $NUMBER_PERSISTENT_VOLUMES Persistent Volumes Provisioned
  while [ ${#K3S_PERSISTENT_VOLUMES[@]} -ne ${NUMBER_PERSISTENT_VOLUMES} ]
  do
    K3S_PERSISTENT_VOLUMES=$(kubectl get pv -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a K3S_PERSISTENT_VOLUMES <<< "$K3S_PERSISTENT_VOLUMES"
  done

  # wait for those $NUMBER_PERSISTENT_VOLUMES Persistent Volumes to be in a Available state
  
  PERSISTENT_VOLUMES_STATUS=$(kubectl get pv -o 'jsonpath={..status.phase}')
  IFS='/ ' read -r -a PERSISTENT_VOLUMES_STATUS <<< "$PERSISTENT_VOLUMES_STATUS"

  for i in "${PERSISTENT_VOLUMES_STATUS[@]}"; do
    while [ "$i" != "Available" ]
    do
      PERSISTENT_VOLUMES_STATUS=$(kubectl get pv -o 'jsonpath={..status.phase}')
      IFS='/ ' read -r -a PERSISTENT_VOLUMES_STATUS <<< "$PERSISTENT_VOLUMES_STATUS"
    done
  done

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Deployment Complete Message to User

  TITLE="Deployment Complete"
  print_title

  printf "${GREEN}CONGRATULATIONS!!! K3s has been successfully deployed.\n${COLOUR_OFF}"
  printf "${GREEN}Your K3s Dashboard is now available @ ${CYAN} https://${DASHBOARD_SUBDOMAIN}.${DOMAIN}\n${COLOUR_OFF}"
  printf "${YELLOW}You will need to generate a token for authentication to the dashboard, you can use the aliased command ${RED}'admin' ${YELLOW}to get one\n${COLOUR_OFF}"
  printf "${GREEN}Here is a token you can use right now (they do expire)\n${COLOUR_OFF}"

  # Generating Dashboard Token
  K3S_TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user)

  printf "${PURPLE}${K3S_TOKEN}\n${COLOUR_OFF}"
