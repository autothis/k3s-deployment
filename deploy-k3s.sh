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
#CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Kubernetes Dashboard e.g. 'prod-issuer' or 'selfsigned-issuer'.

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
    K3S_VARIABLE_9=("CERT_ISSUER" "$CERT_ISSUER" "This is the certificate issuer that will be used to issue a certificate for the Kubernetes Dashboard e.g. 'prod-issuer' or 'selfsigned-issuer'")

    # Combine K3S_VARIABLE arrays int the K3S_VARIABLES array
    COUNT=0
    K3S_VARIABLES=()
    for VARIABLE in "${!K3S_VARIABLE_@}"
    do
      if [[ "$VARIABLE" == K3S_VARIABLE_* ]]; then
	      ((COUNT++))
        K3S_VARIABLES+=('K3S_VARIABLE_'$COUNT[@])
      fi
    done
  }

  print_title () {

    printf ${YELLOW}"#%.0s"  $(seq 1 ${BREAK})
    printf "\n"
    printf "$TITLE \n"
    printf "#%.0s"  $(seq 1 ${BREAK})
    printf "\n"${COLOUR_OFF}
  }

# Define Custom Command Aliases

  # Define K3S_ALIAS arrays containing custom command aliases for kubernetes (ALIAS, COMMAND, EXTRA)
  K3S_ALIAS_1=('kga' '' 'function kga {')
  K3S_ALIAS_2=('kga' '' '  if [[ -z "${1}" ]]')
  K3S_ALIAS_3=('kga' '' '    then')
  K3S_ALIAS_4=('kga' '' '      printf ${RED}"No namespace has been provided\n"')
  K3S_ALIAS_5=('kga' '' '      printf ${GREEN}"Example: "${YELLOW}"'\''kga kube-system'\''\n"${COLOUR_OFF}')
  K3S_ALIAS_6=('kga' '' '    else')
  K3S_ALIAS_7=('kga' '' '      for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do')
  K3S_ALIAS_8=('kga' '' '        printf ${YELLOW}"Resource: "${GREEN}$i${COLOUR_OFF}"\n"')
  K3S_ALIAS_9=('kga' '' '        kubectl -n ${1} get ${i}')
  K3S_ALIAS_10=('kga' '' '      done')
  K3S_ALIAS_11=('kga' '' '  fi')
  K3S_ALIAS_12=('kga' '' '}')
  K3S_ALIAS_13=('k' 'kubectl' 'complete -o default -F __start_kubectl k')
  K3S_ALIAS_14=('admin' '"kubectl -n kubernetes-dashboard create token admin-user"' '')
  K3S_ALIAS_15=('kp' '"kubectl get pods"' '')
  K3S_ALIAS_16=("kpa" '"kubectl get pods -A"' "")
  K3S_ALIAS_17=("kn" '"kubectl get nodes -o wide"' "")
  K3S_ALIAS_18=("kl" '"kubectl logs -f"' "")
  K3S_ALIAS_19=("kc" '"kubectl get certs"' "")
  K3S_ALIAS_20=("kca" '"kubectl get certs -A"' "")
  K3S_ALIAS_21=("ki" '"kubectl get ingress"' "")
  K3S_ALIAS_22=("kia" '"kubectl get ingress -A"' "")
  K3S_ALIAS_23=("ks" '"kubectl get service"' "")
  K3S_ALIAS_24=("ksa" '"kubectl get service -A"' "")
  K3S_ALIAS_25=("kd" '"kubectl get deployment"' "")
  K3S_ALIAS_26=("kda" '"kubectl get deployment -A"' "")
  K3S_ALIAS_27=("kns" '"kubectl get namespace"' "")

  # Combine K3S_ALIAS arrays into the K3S_ALIASES array
  COUNT=0
  K3S_ALIASES=()
  for ALIAS in "${!K3S_ALIAS_@}"
  do
    if [[ "$ALIAS" == K3S_ALIAS_* ]]; then
	  ((COUNT++))
      K3S_ALIASES+=('K3S_ALIAS_'$COUNT[@])
    fi
  done

# Define Output Colours
  
  # Define K3S_COLOUR arrays
  K3S_COLOUR_1=("COLOUR_OFF" "'\033[0m'")
  K3S_COLOUR_2=("BLACK" "'\033[0;30m'")
  K3S_COLOUR_3=("RED" "'\033[0;31m'")
  K3S_COLOUR_4=("GREEN" "'\033[0;32m'")
  K3S_COLOUR_5=("YELLOW" "'\033[0;33m'")
  K3S_COLOUR_6=("BLUE" "'\033[0;34m'")
  K3S_COLOUR_7=("PURPLE" "'\033[0;35m'")
  K3S_COLOUR_8=("CYAN" "'\033[0;36m'")
  K3S_COLOUR_9=("WHITE" "'\033[0;37m'")

  # Combine K3S_COLOUR arrays into the K3S_COLOURS array
  COUNT=0
  K3S_COLOURS=()
  for COLOUR in "${!K3S_COLOUR_@}"
  do
    if [[ "$COLOUR" == K3S_COLOUR_* ]]; then
	  ((COUNT++))
      K3S_COLOURS+=('K3S_COLOUR_'$COUNT[@])
    fi
  done  

  # Active K3S_COLOURS in current user session
  COUNT=${#K3S_COLOURS[@]}
  for ((i=0; i<$COUNT; i++))
  do
    NAME=${!K3S_COLOURS[i]:0:1}
    COLOUR=${!K3S_COLOURS[i]:1:1}
	  eval "$NAME=$COLOUR"
  done

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

  TITLE="Updating User Profile with custom kubectl aliases, functions and colours"
  print_title

  cd $K3S_DEPLOY_PATH

  # Iterate over the K3S_COLOURS array, adding each colour to '/etc/profile'
  COUNT=${#K3S_COLOURS[@]}
  for ((i=0; i<$COUNT; i++))
  do
    NAME=${!K3S_COLOURS[i]:0:1}
    COLOUR=${!K3S_COLOURS[i]:1:1}
    printf "Adding colour \'$NAME\' to profile\n"
    echo "$NAME=$COLOUR" >> /etc/profile
  done
  
  # Iterate over the K3S_ALIASES array, adding each command alias to '/etc/profile'
  COUNT=${#K3S_ALIASES[@]}
  for ((i=0; i<$COUNT; i++))
  do
    ALIAS=${!K3S_ALIASES[i]:0:1}
    COMMAND=${!K3S_ALIASES[i]:1:1}
    EXTRA=${!K3S_ALIASES[i]:2:1}

    if [[ -z "${EXTRA}" ]]; then
      printf "Configuring alias for \'$ALIAS\' -> $COMMAND\n"
      echo "alias $ALIAS=$COMMAND" >> /etc/profile
    else
	  if [[ -z "${COMMAND}" ]]; then
        printf "Configuring function for \'$ALIAS\': \'$EXTRA\'\n"
		echo "$EXTRA" >> /etc/profile
	  else
	    printf "Configuring alias for \'$ALIAS\' -> \'$COMMAND\'\n"
        echo "alias $ALIAS=$COMMAND" >> /etc/profile
	    echo "$EXTRA" >> /etc/profile
	  fi
    fi
  done
  
  # Update current user session with new command aliases
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
  sudo systemctl daemon-reload

  for i in $(seq 1 $NUMBER_PERSISTENT_VOLUMES); do
    sudo mkdir -p /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i}
    sudo mount --bind /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i}
  done

  for i in $(seq 1 $NUMBER_PERSISTENT_VOLUMES); do
    echo /mnt/${DISK_UUID}/vol${i} /mnt/disks/${DISK_UUID}_vol${i} none bind 0 0 | sudo tee -a /etc/fstab
    sudo systemctl daemon-reload
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
    kubectl wait -n kube-system --for=condition=Ready pod/${i} --timeout=${TIMEOUT}s
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

  sudo apt-get install curl gpg apt-transport-https --yes
  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm --yes

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
    kubectl wait -n ${INGRESS_CONTROLLER_NAMESPACE} --for=condition=Ready pod/${i} --timeout=${TIMEOUT}s
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
    kubectl wait -n cert-manager --for=condition=Ready pod/${i} --timeout=${TIMEOUT}s
  done

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Configure prod-issuer if selected

  if [[ ${CERT_ISSUER} = "prod-issuer" ]]
  then
  # Update File 'cloudflare-secret.yaml'

    TITLE="Updating file cloudflare-secret.yaml with K3s Deployment Variables"
    print_title

    sed -i "s/CLOUDFLARE_API_TOKEN/$CLOUDFLARE_API_TOKEN/g" cert-manager/cloudflare-secret.yaml

    printf "${GREEN}Done\n${COLOUR_OFF}"

  # Create File 'prod-issuer.yaml'

    TITLE="Updating file prod-issuer.yaml with K3s Deployment Variables"
    print_title

    sed -i "s/CLOUDFLARE_EMAIL_ADDRESS/$CLOUDFLARE_EMAIL_ADDRESS/g" cert-manager/prod-issuer.yaml

    printf "${GREEN}Done\n${COLOUR_OFF}"

  # Create Cert-Manager Production (Cloudflare) Issuer

    TITLE="Creating Cert-Manager prod-issuer"
    print_title

    kubectl create -f cert-manager/cloudflare-secret.yaml
    kubectl create -f cert-manager/prod-issuer.yaml

    printf "${GREEN}Done\n${COLOUR_OFF}"

  # Wait for Cert-Manager prod-issuer

    TITLE="Waiting for Cert-Manager prod-issuer to be ready"
    print_title
  
    kubectl wait --for=condition=Ready clusterissuers.cert-manager.io prod-issuer --timeout=${TIMEOUT}s
  fi

# Configure selfsigned-issuer if selected

  if [[ ${CERT_ISSUER} = "selfsigned-issuer" ]]
  then
  # Create Cert-Manager Self Signed CA Issuer

    TITLE="Creating Cert-Manager Self Signed CA Issuer"
    print_title
  
    kubectl create -f cert-manager/selfsigned-ca-issuer.yaml
    kubectl create -f cert-manager/ca-certificate.yaml

  # Wait for Cert-Manager Self Signed CA Issuer and Certificate

    TITLE="Waiting for Cert-Manager Self Signed CA Issuer and Certificate"
    print_title
  
    kubectl wait --for=condition=Ready clusterissuers.cert-manager.io selfsigned-ca-issuer --timeout=${TIMEOUT}s
    kubectl --namespace cert-manager wait --for=condition=Ready certificates.cert-manager.io selfsigned-ca --timeout=${TIMEOUT}s

  # Create Cert-Manager Self Signed Issuer

    TITLE="Creating Cert-Manager selfsigned-issuer"
    print_title

    kubectl create -f cert-manager/selfsigned-issuer.yaml

    printf "${GREEN}Done\n${COLOUR_OFF}"

  # Wait for Cert-Manager selfsigned-issuer

    TITLE="Waiting for Cert-Manager selfsigned-issuer to be ready"
    print_title
  
    kubectl wait --for=condition=Ready clusterissuers.cert-manager.io selfsigned-issuer --timeout=${TIMEOUT}s

  # Get CA Certificate and Install into K3s Host

    TITLE="Installing CA on K3s Host"
    print_title

    # Create Custom CA Location
    CUSTOM_CA_LOCATION="/usr/local/share/ca-certificates/k3s"
    mkdir $CUSTOM_CA_LOCATION

    # Retrieve Self Signed CA Certificate
    SELFSIGNED_CA_CERTIFICATE=$(kubectl get secrets/tls-selfsigned-ca --namespace cert-manager -o 'jsonpath={..data.tls\.crt}' | base64 -d)

    # Install Self Signed CA Certificate  
    printf '%s\n' "$SELFSIGNED_CA_CERTIFICATE" > $CUSTOM_CA_LOCATION/k3s-custom-ca.crt

    # Update K3s Host CA Certificate Store
    update-ca-certificates
  fi

# Create File 'values.yaml' for Kubernetes Dashboard Helm Deployment

  TITLE="Updating file values.yaml with K3s Deployment Variables"
  print_title

  sed -i "s/DASHBOARD_SUBDOMAIN/$DASHBOARD_SUBDOMAIN/g" kubernetes-dashboard/values.yaml
  sed -i "s/DOMAIN/$DOMAIN/g" kubernetes-dashboard/values.yaml
  sed -i "s/CERT_ISSUER/$CERT_ISSUER/g" kubernetes-dashboard/values.yaml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Install Kubernetes Dashboard

  TITLE="Installing Kubernetes Dashboard in Namespace ${INGRESS_CONTROLLER_NAMESPACE}"
  print_title

  # Set Kubernetes Dashboard Namespace, default is "kubernetes-dashboard"
  KUBERNETES_DASHBOARD_NAMESPACE="kubernetes-dashboard"

  # Add kubernetes-dashboard repository
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  # Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
  helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace $KUBERNETES_DASHBOARD_NAMESPACE -f kubernetes-dashboard/values.yaml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Kubernetes Dashboard to be Ready

  TITLE="Waiting for Kubernetes Dashboard to be Ready"
  print_title

  KUBERNETES_DASHBOARD_PODS=$(kubectl get pods -n ${KUBERNETES_DASHBOARD_NAMESPACE} -o 'jsonpath={..metadata.name}')
  IFS='/ ' read -r -a KUBERNETES_DASHBOARD_PODS <<< "$KUBERNETES_DASHBOARD_PODS"

  # wait for there to be 5 pods in the $KUBERNETES_DASHBOARD_NAMESPACE namespace
  while [ ${#KUBERNETES_DASHBOARD_PODS[@]} -ne 5 ]
  do
    KUBERNETES_DASHBOARD_PODS=$(kubectl get pods -n ${KUBERNETES_DASHBOARD_NAMESPACE} -o 'jsonpath={..metadata.name}')
    IFS='/ ' read -r -a KUBERNETES_DASHBOARD_PODS <<< "$KUBERNETES_DASHBOARD_PODS"
  done

  # wait for those 5 pods to be in a ready state
  for i in "${KUBERNETES_DASHBOARD_PODS[@]}"; do
    kubectl wait -n ${KUBERNETES_DASHBOARD_NAMESPACE} --for=condition=Ready pod/${i} --timeout=${TIMEOUT}s
  done

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Create Dashboard, Dashboard User Admin, Admin Role, and Dashboard Ingress

  TITLE="Creating and configuring K3s Dashboard Roles and Users"
  print_title

  kubectl create -f kubernetes-dashboard/kubernetes-dashboard.yaml
  kubectl create -f kubernetes-dashboard/dashboard-admin-user.yaml -f kubernetes-dashboard/dashboard-admin-user-role.yaml

  printf "${GREEN}Done\n${COLOUR_OFF}"

# Provision Storage

  TITLE="Creating Persistent Volume Provisioner"
  print_title

  kubectl apply -f sig-storage/persistent-volume-provisioner.yaml

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

# remove default storage class annotation from local-path

  TITLE="Removing the annotation from the default storageClass local-path"
  print_title

  kubectl annotate --overwrite storageClass local-path storageclass.kubernetes.io/is-default-class=false

# Wait for Certificate to be assigned

	TITLE="Waiting for K3s Dashboard Certificate to be Ready"
	print_title

	# Query Certificates status in the Kubernetes-Dashboard Namespace
	K3S_DASHBOARD_CERTIFICATE=$(kubectl get certificate -n kubernetes-dashboard -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a K3S_DASHBOARD_CERTIFICATE <<< "$K3S_DASHBOARD_CERTIFICATE"
	for i in "${K3S_DASHBOARD_CERTIFICATE[@]}"; do
		kubectl wait -n kubernetes-dashboard --for=condition=Ready certificate/${i} --timeout=${TIMEOUT}s
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

  if [[ ${CERT_ISSUER} = "selfsigned-issuer" ]]
  then
    printf "${YELLOW}You will need to install the Self Signed CA Certificate on any machines you dont want to get TLS warnings on.\n${COLOUR_OFF}"
    printf "${GREEN}The Self Signed CA Certificate has been automatically added to your K3 Hosts CA Store.\n${COLOUR_OFF}"
    printf "${RED}Your Self Signed CA Certificate is:\n${COLOUR_OFF}"
    printf '%s\n' "${SELFSIGNED_CA_CERTIFICATE}"
  fi
  