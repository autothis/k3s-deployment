#!/bin/bash

#Define variables for K3s deployment (uncomment lines, and populate variables - not required if using other methods of variables population).

  #k3dsk='' #This is the disk you will be assigning Persistent Volumes to K3s from.
  #diskno='' #This is the amount of persistent volumes to be created, keep in mind that there is no consumption controll (they share the same disk).
  #dashdns='' #This is the subdomain that will be used to serve your Kubernetes Dashboard.
  #ingns='' #This is the namespace that the NGINX ingress will be deployed to.
  #ingname='' #This is the name prepended to the nginx-ingress pod name.
  #cftoken='' #This is the cloudflare token to be used by cert-manager.
  #cfemail='' #This is the email address that will be associated with your LetsEncrypt certificates e.g. 'youremailaddress@here.com'.
  #domain='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.

#Create Functions

  set_k3vars () {

    # Define k3var array containing required variables for K3s deployment
    k3var_1=("k3dsk" "$k3dsk" "This is the disk you will be assigning Persistent Volumes to K3s from e.g. '/dev/sdb'")
    k3var_2=("diskno" "$diskno" "This is the amount of persistent volumes to be created e.g. '4'")
    k3var_3=("dashdns" "$dashdns" "This is the subdomain that will be used to serve your Kubernetes Dashboard. e.g. 'k3s' will become k3s.yourdomain.com")
    k3var_4=("ingns" "$ingns" "This is the namespace that the NGINX ingress will be deployed to e.g. 'kubernetes-ingress'")
    k3var_5=("ingname" "$ingname" "This is the name prepended to the nginx-ingress pod name e.g. 'primary'")
    k3var_6=("cftoken" "$cftoken" "This is the cloudflare token to be used by cert-manager e.g. 'ZN0tr3AL9sEHl19yqjHzpy_fAkET0keNn_ddqg_y'")
    k3var_7=("cfemail" "$cfemail" "This is the email address that will be associated with your LetsEncrypt certificates e.g. 'youremailaddress@here.com'")
    k3var_8=("domain" "$domain" "This is the domain that your services will be available on e.g. 'yourdomain.com'")

   # Combine k3var arrays int the k3vars array
   k3vars=(
     k3var_1[@]
     k3var_2[@]
     k3var_3[@]
     k3var_4[@]
     k3var_5[@]
     k3var_6[@]
     k3var_7[@]
     k3var_8[@]
   )
  }

  print_title () {

    printf ${Yellow}"#%.0s"  $(seq 1 150)
    printf "\n"
    printf "$title \n"
    printf "#%.0s"  $(seq 1 150)
    printf "\n"${Color_Off}

  }

#Define Output Colours

  # Reset
  Color_Off='\033[0m'       # Text Reset

  # Regular Colors
  Black='\033[0;30m'        # Black
  Red='\033[0;31m'          # Red
  Green='\033[0;32m'        # Green
  Yellow='\033[0;33m'       # Yellow
  Blue='\033[0;34m'         # Blue
  Purple='\033[0;35m'       # Purple
  Cyan='\033[0;36m'         # Cyan
  White='\033[0;37m'        # White

# Get current working directory

  k3sdeploypath=$(pwd)

# Set K3 Variables

  set_k3vars
  k3missingvars=()

#Print Local Disk Table

  title="Local Disk Table"
  print_title

  lsblk -f

#Missing Variables

  title="Looking for missing K3s Deployment Variables"
  print_title

  # Loop k3vars looking for missing variables

    COUNT=${#k3vars[@]}
    for ((i=0; i<$COUNT; i++))
    do
      NAME=${!k3vars[i]:0:1}
      VALUE=${!k3vars[i]:1:1}
      DESC=${!k3vars[i]:2:1}

      if [[ -z "${VALUE}" ]]; then
        echo "Name: ${NAME}"
        printf "Value: ${Red}${NAME} is undefined\n${Color_Off}"
        echo "Description: ${DESC}"
        printf ${White}"=%.0s"  $(seq 1 150)${Color_Off}
        printf "\n${Color_Off}"
        k3missingvars+=( "k3var_$(expr $i + 1)[@]" )
      fi
    done

  # Loop k3missingvars to give user option to define any missing variables

    COUNT=${#k3missingvars[@]}
    for ((i=0; i<$COUNT; i++))
    do
      NAME=${!k3missingvars[i]:0:1}
      VALUE=${!k3missingvars[i]:1:1}
      DESC=${!k3missingvars[i]:2:1}

      printf "${Yellow}No value provided for '${NAME}'\n${Color_Off}"
      printf "$DESC\n"
      read -p "$(printf "${Cyan}Provide a value for '${NAME}': ${Green}")" $NAME
      printf "${Color_Off}"
    done

# Update K3 Variables

  set_k3vars
  clear

# Loop k3vars to display variables to be used for K3s deployment.

  title="Variables to be using in K3s Deployment"
  print_title

  COUNT=${#k3vars[@]}
  for ((i=0; i<$COUNT; i++))
  do
    NAME=${!k3vars[i]:0:1}
    VALUE=${!k3vars[i]:1:1}
    DESC=${!k3vars[i]:2:1}

    if [[ -z "${VALUE}" ]]; then
      echo "Name: ${NAME}"
      printf "Value: ${Red}${NAME} is undefined\n${Color_Off}"
      echo "Description: ${DESC}"
      printf ${White}"=%.0s"  $(seq 1 150)${Color_Off}
      printf "\n${Color_Off}"
    else
      printf "Name: ${Cyan}${NAME}\n${Color_Off}"
      printf "Value: ${Green}${VALUE}\n${Color_Off}"
      printf "Description: ${White}${DESC}\n${Color_Off}"
      printf ${Blue}"=%.0s"  $(seq 1 150) \n
      printf "\n${Color_Off}"
    fi
  done

#Confirm Variables before Deployment

  read -p "$(printf "${Yellow}Would you like to proceed with deployment, based on the variables listed above? [y/N] ${Color_Off}")" -r
  if [[ $REPLY =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    printf "${Green}Proceeding with provided variables...\n${Color_Off}"
  elif [[ $REPLY =~ ^([nN][oO]|[nN])$ ]]
  then
    printf "${Red}You have chosen not to proceed, exiting...\n${Color_Off}"
    exit
  else
    printf "${Red}You have provided an invaild answer, exiting...\n${Color_Off}"
    exit
  fi

#Install Prerequisites

  title="Installing Prerequisites"
  print_title

  apt install sudo git curl gpg apt-transport-https --yes

  printf "${Green}Done\n${Color_Off}"

#Install Kustomize

  title="Installing Kustomize"
  print_title

  #https://github.com/kubernetes-sigs/kustomize
  cd /usr/bin
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

  printf "${Green}Done\n${Color_Off}"

#Update Profiles

  title="Updating User Profile"
  print_title

  cd $k3sdeploypath
  echo "alias k=kubectl" >> /etc/profile
  echo "complete -o default -F __start_kubectl k" >> /etc/profile
  echo "alias admin='kubectl -n kubernetes-dashboard create token admin-user'" >> /etc/profile
  source /etc/profile

  printf "${Green}Done\n${Color_Off}"

#Disable SWAP

  title="Disabling SWAP"
  print_title

  swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  echo "Dont forget to reclaim space if you want to."

  printf "${Green}Done\n${Color_Off}"

#Configure Secondary Disk

  title="Configuring Secondary Disk for K3s Persistent Volumes"
  print_title

  printf "o\nn\np\n1\n\n\nw\n" | sudo fdisk $k3dsk
  sudo mkfs.ext4 ${k3dsk}1
  DISK_UUID=$(blkid -s UUID -o value ${k3dsk}1)
  sudo mkdir /mnt/$DISK_UUID
  sudo mount -t ext4 ${k3dsk}1 /mnt/$DISK_UUID
  echo UUID=`sudo blkid -s UUID -o value ${k3dsk}1` /mnt/$DISK_UUID ext4 defaults 0 2 | sudo tee -a /etc/fstab

  for i in $(seq 1 $diskno); do
    sudo mkdir -p /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i}
    sudo mount --bind /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i}
  done

  for i in $(seq 1 $diskno); do
    echo /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i} none bind 0 0 | sudo tee -a /etc/fstab
  done

  printf "${Green}Done\n${Color_Off}"

#Install K3s

  title="Installing K3s (without Traefik)"
  print_title

  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -s -
  mkdir ~/.kube
  kubectl config view --raw > ~/.kube/config

  printf "${Green}Done\n${Color_Off}"

#Wait for K3s to be Ready

  title="Waiting for K3s to be Ready"
  print_title

  k3spods=$(kubectl get pods -n kube-system -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a k3spods <<< "$k3spods"

  #wait for there to be 4 pods in the kube-system namespace
  while [ ${#k3spods[@]} -ne 3 ]
  do
    k3spods=$(kubectl get pods -n kube-system -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a k3spods <<< "$k3spods"
  done

  #wait for those 4 pods to be in a ready state
  for i in "${k3spods[@]}"; do
    kubectl wait --for=condition=Ready pod/${i} --timeout=300s
  done

  printf "${Green}Done\n${Color_Off}"

#Install Helm

  title="Installing Helm"
  print_title

  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
  apt update
  apt install helm --yes

  printf "${Green}Done\n${Color_Off}"

#Install NGINX Ingress Controller

  title="Installing NGINX Ingress Controller: ${ingname}-nginx-ingress in Namespace ${ingns}"
  print_title

  #https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
  helm repo add nginx-stable https://helm.nginx.com/stable
  helm repo update
  helm install "$ingname" nginx-stable/nginx-ingress --namespace "$ingns" --create-namespace

  printf "${Green}Done\n${Color_Off}"

#Wait for NGINX Ingresss Controller to be Ready

  title="Waiting for NGINX Ingress Controller to be Ready"
  print_title

  nginxingpods=$(kubectl get pods -n ${ingns} -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a nginxingpods <<< "$nginxingpods"

  #wait for there to be 1 pod in the NGINX Ingress Controller namespace
  while [ ${#nginxingpods[@]} -ne 1 ]
  do
    nginxingpods=$(kubectl get pods -n ${ingns} -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a nginxingpods <<< "$nginxingpods"
  done

  #wait for that 1 pod to be in a ready state
  for i in "${nginxingpods[@]}"; do
    kubectl wait -n ${ingns} --for=condition=Ready pod/${i} --timeout=300s
  done

  printf "${Green}Done\n${Color_Off}"

#Install Cert Manager

  title="Installing Cert Manager in Namespace cert-manager"
  print_title

  #https://www.nginx.com/blog/automating-certificate-management-in-a-kubernetes-environment/
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.9.1 --set installCRDs=true

  printf "${Green}Done\n${Color_Off}"

#Wait for Cert Manager to be Ready

  title="Waiting for Cert Manager to be Ready"
  print_title

  certmgrpods=$(kubectl get pods -n cert-manager -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a certmgrpods <<< "$certmgrpods"

  #wait for there to be 3 pods in the cert-manager namespace
  while [ ${#certmgrpods[@]} -ne 3 ]
  do
    certmgrpods=$(kubectl get pods -n cert-manager -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a certmgrpods <<< "$certmgrpods"
  done

  #wait for those 3 pods to be in a ready state
  for i in "${certmgrpods[@]}"; do
    kubectl wait -n cert-manager --for=condition=Ready pod/${i} --timeout=300s
  done

  printf "${Green}Done\n${Color_Off}"

#Update File 'cloudflare-secret.yml'

  title="Updating file cloudflare-secret.yml with K3s Deployment Variables"
  print_title

  sed -i "s/cftoken/$cftoken/g" cert-manager/cloudflare-secret.yml

  printf "${Green}Done\n${Color_Off}"

#Create File 'cloudflare-dns-challenge.yml'

  title="Updating file cloudflare-dns-challenge.yml with K3s Deployment Variables"
  print_title

  sed -i "s/cfemail/$cfemail/g" cert-manager/cloudflare-dns-challenge.yml

  printf "${Green}Done\n${Color_Off}"

#Create Cloudflare Secret and DNS Challenge

  title="Creating Cloudflare Secret and DNS Challenge"
  print_title

  kubectl create -f cert-manager/cloudflare-secret.yml
  kubectl create -f cert-manager/cloudflare-dns-challenge.yml

  printf "${Green}Done\n${Color_Off}"

#Create File 'kubernetes-dashboard.yml'

  title="Downloading file kubernetes-dashboard.yml"
  print_title

  GITHUB_URL=https://github.com/kubernetes/dashboard/releases
  VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
  curl https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml > kubernetes-dashboard/kubernetes-dashboard.yml

  printf "${Green}Done\n${Color_Off}"

#Create File 'dashboard-ingress.yml'

  title="Updating file dashboard-ingress.yml with K3s Deployment Variables"
  print_title

  sed -i "s/domain/$domain/g" kubernetes-dashboard/dashboard-ingress.yml
  sed -i "s/dashdns/$dashdns/g" kubernetes-dashboard/dashboard-ingress.yml

  printf "${Green}Done\n${Color_Off}"

#Create Dashboard, Dashboard User Admin, Admin Role, and Dashboard Ingress

  title="Creating and configuring K3s Dashboard and associated roles, users and ingress"
  print_title

  kubectl create -f kubernetes-dashboard/kubernetes-dashboard.yml
  kubectl create -f kubernetes-dashboard/dashboard-admin-user.yml -f kubernetes-dashboard/dashboard-admin-user-role.yml
  kubectl create -f kubernetes-dashboard/dashboard-ingress.yml

  printf "${Green}Done\n${Color_Off}"

#Wait for Kubernetes Dashboard to be Ready

  title="Waiting for Kubernetes Dashboard to be Ready"
  print_title

  k3sdashpods=$(kubectl get pods -n kubernetes-dashboard -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a k3sdashpods <<< "$k3sdashpods"

  #wait for there to be 3 pods in the kubernetes-dashboard namespace
  while [ ${#k3sdashpods[@]} -ne 2 ]
  do
    k3sdashpods=$(kubectl get pods -n kubernetes-dashboard -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a k3sdashpods <<< "$k3sdashpods"
  done

  #wait for those 2 pods to be in a ready state
  for i in "${k3sdashpods[@]}"; do
    kubectl wait -n kubernetes-dashboard --for=condition=Ready pod/${i} --timeout=300s
  done

  printf "${Green}Done\n${Color_Off}"

#Provision Storage

  title="Creating Persistent Volume Provisioner"
  print_title

  kubectl apply -f sig-storage/persistent-volume-provisioner.yml

  printf "${Green}Done\n${Color_Off}"

#Wait for Persistent Volumes to be Ready

  title="Waiting for Persistent Volumes to be Ready"
  print_title

  k3spv=$(kubectl get pv -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a k3spv <<< "$k3spv"

  #wait for there to be $diskno Persistent Volumes Provisioned
  while [ ${#k3spv[@]} -ne ${diskno} ]
  do
    k3spv=$(kubectl get pv -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a k3spv <<< "$k3spv"
  done

  #wait for those $diskno Persistent Volumes to be in a Available state
  
  pvstat=$(kubectl get pv -o 'jsonpath={..status.phase}')
  IFS='/ ' read -r -a pvstat <<< "$pvstat"

  for i in "${pvstat[@]}"; do
    while [ "$i" != "Available" ]
    do
      pvstat=$(kubectl get pv -o 'jsonpath={..status.phase}')
      IFS='/ ' read -r -a pvstat <<< "$pvstat"
    done
  done

  printf "${Green}Done\n${Color_Off}"

#Deployment Complete Message to User

  title="Deployment Complete"
  print_title

  printf "${Green}CONGRATULATIONS!!! K3s has been successfully deployed.\n${Color_Off}"
  printf "${Green}Your K3s Dashboard is now available @ ${Cyan} https://${dashdns}.${domain}\n${Color_Off}"
  printf "${Yellow}You will need to generate a token for authentication to the dashboard, you can use the aliased command ${Red}'admin' ${Yellow}to get one\n${Color_Off}"
  printf "${Green}Here is a token you can use right now (they do expire)\n${Color_Off}"

  #Generating Dashboard Token
  k3stoken=$(kubectl -n kubernetes-dashboard create token admin-user)

  printf "${Purple}${k3stoken}\n${Color_Off}"
