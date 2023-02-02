#!/bin/bash

# Define variables for K3s deployment (uncomment lines, and populate variables - not required if using other methods of variables population).

  #k3dsk='' #This is the disk you will be assigning Persistent Volumes to K3s from.
  #diskno='' #This is the amount of persistent volumes to be created, keep in mind that there is no consumption controll (they share the same disk).
  #ingns='' #This is the namespace that the NGINX ingress will be deployed to.
  #ingname='' #This is the name prepended to the nginx-ingress pod name.
  #cftoken='' #This is the cloudflare token to be used by cert-manager.
  #cfemail='' #This is the email address that will be associated with your LetsEncrypt certificates e.g. 'youremailaddress@here.com'.
  #domain='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.

#Create Functions

  set_k3vars () {
    
    # Define k3var array containing required variables for K3s deployment
    k3var_1=("k3dsk" "$k3dsk" "This is the disk you will be assigning Persistent Volumes to K3s from e.g. '/dev/sdb'")
    k3var_2=("diskno" "$diskno" "This is the amount of persistent volumes to be created, keep in mind that there is no consumption controll [they share the same disk, only isolated by folder structure] e.g. '4'")
    k3var_3=("ingns" "$ingns" "This is the namespace that the NGINX ingress will be deployed to e.g. 'kubernetes-ingress'")
    k3var_4=("ingname" "$ingname" "This is the name prepended to the nginx-ingress pod name e.g. 'primary'")
    k3var_5=("cftoken" "$cftoken" "This is the cloudflare token to be used by cert-manager e.g. 'ZM8z4JS9dEHl19yvjHzpk_kEiEWG7qxUn_dwhg_z'")
    k3var_6=("cfemail" "$cfemail" "This is the email address that will be associated with your LetsEncrypt certificates e.g. 'youremailaddress@here.com'")
    k3var_7=("domain" "$domain" "This is the domain that your services will be available on e.g. 'yourdomain.com'")
    
   # Combine k3var arrays int the k3vars array
   k3vars=(
     k3var_1[@]
     k3var_2[@]
     k3var_3[@]
     k3var_4[@]
     k3var_5[@]
     k3var_6[@]
     k3var_7[@]
   )
  }
  
  print_title () {
  
    printf ${Yellow}"#%.0s"  $(seq 1 100)
    printf "\n"
    printf "$title \n"
    printf "#%.0s"  $(seq 1 100)
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
    	printf ${White}"=%.0s"  $(seq 1 100)${Color_Off}
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
      
      read -p "Would you like to provide a value for $NAME? " -r
      echo    # (optional) move to a new line
      if [[ $REPLY =~ ^[Yy]$ ]]
      then
          read -p "Enter value for $NAME: " $NAME
      fi
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
  	printf ${White}"=%.0s"  $(seq 1 100)${Color_Off}
  	printf "\n${Color_Off}"
    else
      printf "Name: ${Cyan}${NAME}\n${Color_Off}"
      printf "Value: ${Green}${VALUE}\n${Color_Off}"
  	printf "Description: ${White}${DESC}\n${Color_Off}"
  	printf ${Blue}"=%.0s"  $(seq 1 100) \n 
  	printf "\n${Color_Off}"
    fi
  done

#Install Prerequisites

  title="Installing Prerequisites"
  print_title 

  apt install sudo git curl gpg apt-transport-https --yes
  
  echo "done"

#Install Kustomize

  title="Installing Kustomize"
  print_title 

  #https://github.com/kubernetes-sigs/kustomize
  cd /usr/bin
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
  
  echo "done"

#Update Profiles

  title="Updating User Profile"
  print_title 
  
  cd $k3sdeploypath
  echo "alias k=kubectl" >> /etc/profile
  echo "complete -o default -F __start_kubectl k" >> /etc/profile
  echo "alias admin='kubectl -n kubernetes-dashboard create token admin-user'" >> /etc/profile
  source /etc/profile
  
  echo "done"

#Disable SWAP
  
  title="Disabling SWAP"
  print_title 
  
  swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  echo "Dont forget to reclaim space if you want to."
  
  echo "done"

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
  
  echo "done"
  
#Install K3s

  title="Installing K3s (without Treafik)"
  print_title 
  
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -s -
  mkdir ~/.kube
  kubectl config view --raw > ~/.kube/config
  
  echo "done"

#Install Helm

  title="Installing Helm"
  print_title 
  
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
  apt update
  apt install helm --yes
  
  echo "done"

#Install NGINX Ingress Controller

  title="Installing NGINX Ingress Controller: ${ingname}-nginx-ingress in Namespace ${ingns}"
  print_title 
  
  #https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
  helm repo add nginx-stable https://helm.nginx.com/stable
  helm repo update
  helm install "$ingname" nginx-stable/nginx-ingress --namespace "$ingns" --create-namespace
  
  echo "done"
	
#Cert Manager

  title="Installing Cert Manager in Namespace cert-manager"
  print_title 
  
  #https://www.nginx.com/blog/automating-certificate-management-in-a-kubernetes-environment/
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.9.1 --set installCRDs=true 


#Update File 'cloudflare-secret.yml'

  title="Updating file cloudflare-secret.yml with K3s Deployment Variables"
  print_title 
  
  sed -i "s/cftoken/$cftoken/g" cert-manager/cloudflare-secret.yml
  
  echo "done"

#Create File 'cloudflare-dns-challenge.yml'

  title="Updating file cloudflare-dns-challenge.yml with K3s Deployment Variables"
  print_title 
  
  sed -i "s/cfemail/$cfemail/g" cert-manager/cloudflare-dns-challenge.yml
  
  echo "done"

#Create File 'kubernetes-dashboard.yml'

  title="Downloading file kubernetes-dashboard.yml"
  print_title 

  GITHUB_URL=https://github.com/kubernetes/dashboard/releases
  VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
  curl https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yml > kubernetes-dashboard/kubernetes-dashboard.yml
  
  echo "done"

#Create File 'dashboard-ingress.yml'

  title="Updating file dashboard-ingress.yml with K3s Deployment Variables"
  print_title 
  
  sed -i "s/domain/$domain/g" kubernetes-dashboard/dashboard-ingress.yml
  
  echo "done"

#Create Dashboard, Dashboard User Admin, Admin Role, and Dashboard Ingress
  
  title="Creating and configuring K3s Dashboard and associated roles, users and ingress"
  print_title 
  
  kubectl create -f kubernetes-dashboard/kubernetes-dashboard.yml
  kubectl create -f kubernetes-dashboard/dashboard-admin-user.yml -f kubernetes-dashboard/dashboard-admin-user-role.yml
  kubectl create -f kubernetes-dashboard/kubernetes-ingress.yml

  printf "${Green}Your K3s Dashboard is now available @ https://dashboard.${domain}\n${Color_Off}"
  
  echo "done"

#Provision Storage

  title="Creating Persistent Volume Provisioner"
  print_title 
  
  kubectl apply -f sig-storage/persistent-volume-provisioner.yml
  
  echo "done"
