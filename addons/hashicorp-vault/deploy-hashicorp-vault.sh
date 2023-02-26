#!/bin/bash

# Define variables for Hashicorp Vault deployment on K3s (uncomment lines, and populate variables - not required if using other methods of variable population).

	#HASHICORP_VAULT_NAMESPACE='' #This is the namespace that Hashicorp Vault will be deployed to e.g. 'hashicorp-vault'.
	#HASHICORP_VAULT_SUBDOMAIN='' #This is the subdomain that will be used to serve your Hashicorp Vault web UI e.g. 'vault'.
	#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
	#CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Hashicorp Vault e.g. 'prod-issuer' or 'selfsigned-issuer'.

#Create Functions

	set_hashicorp-vault () {

		# Define HASHICORP_VAULT_VARIABLE array containing required variables for K3s deployment
		HASHICORP_VAULT_VARIABLE_1=("HASHICORP_VAULT_NAMESPACE" "$HASHICORP_VAULT_NAMESPACE" "This is the namespace that Hashicorp Vault will be deployed to e.g. 'hashicorp-vault'.")
		HASHICORP_VAULT_VARIABLE_2=("HASHICORP_VAULT_SUBDOMAIN" "$HASHICORP_VAULT_SUBDOMAIN" "This is the subdomain that will be used to serve your Hashicorp Vault web UI e.g. 'vault'.")
		HASHICORP_VAULT_VARIABLE_3=("DOMAIN" "$DOMAIN" "This is the domain that your services will be available on e.g. 'yourdomain.com'.")
		HASHICORP_VAULT_VARIABLE_4=("CERT_ISSUER" "$CERT_ISSUER" "This is the certificate issuer that will be used to issue a certificate for the Hashicorp Vault e.g. 'prod-issuer' or 'selfsigned-issuer'.")

	 # Combine HASHICORP_VAULT_VARIABLE arrays into the HASHICORP_VAULT_VARIABLES array
	 HASHICORP_VAULT_VARIABLES=(
		HASHICORP_VAULT_VARIABLE_1[@]
		HASHICORP_VAULT_VARIABLE_2[@]
		HASHICORP_VAULT_VARIABLE_3[@]
		HASHICORP_VAULT_VARIABLE_4[@]
	 )
	}

	print_title () {

		printf ${YELLOW}"#%.0s"	$(seq 1 ${BREAK})
		printf "\n"
		printf "$TITLE \n"
		printf "#%.0s"	$(seq 1 ${BREAK})
		printf "\n"${COLOUR_OFF}

	}

#Define Output Colours

	# Reset
	COLOUR_OFF='\033[0m'			 # Text Reset

	# Regular Colors
	BLACK='\033[0;30m'				# BLACK
	RED='\033[0;31m'					# RED
	GREEN='\033[0;32m'				# GREEN
	YELLOW='\033[0;33m'			 # YELLOW
	BLUE='\033[0;34m'				 # BLUE
	PURPLE='\033[0;35m'			 # PURPLE
	CYAN='\033[0;36m'				 # CYAN
	WHITE='\033[0;37m'				# WHITE

# Get current working directory

	K3S_DEPLOY_PATH=$(pwd)

# Timeout in seconds

	TIMEOUT=300

# Break width '='

	BREAK=150

# Set Hashicorp Vault Variables

	set_kube-prometheus-stack-variables
	HASHICORP_VAULT_MISSING_VARIABLES=()

# Missing Variables

	TITLE="Looking for missing Hashicorp Vault Deployment Variables"
	print_title

	# Loop HASHICORP_VAULT_VARIABLES looking for missing variables
	COUNT=${#HASHICORP_VAULT_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!HASHICORP_VAULT_VARIABLES[i]:0:1}
		VALUE=${!HASHICORP_VAULT_VARIABLES[i]:1:1}
		DESC=${!HASHICORP_VAULT_VARIABLES[i]:2:1}
		if [[ -z "${VALUE}" ]]; then
			echo "Name: ${NAME}"
			printf "Value: ${RED}${NAME} is undefined\n${COLOUR_OFF}"
			echo "Description: ${DESC}"
			printf ${WHITE}"=%.0s"	$(seq 1 ${BREAK})${COLOUR_OFF}
			printf "\n${COLOUR_OFF}"
			HASHICORP_VAULT_MISSING_VARIABLES+=( "HASHICORP_VAULT_VARIABLE_$(expr $i + 1)[@]" )
		fi
	done

	# Loop HASHICORP_VAULT_MISSING_VARIABLES to give user option to define any missing variables
	COUNT=${#HASHICORP_VAULT_MISSING_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!HASHICORP_VAULT_MISSING_VARIABLES[i]:0:1}
		VALUE=${!HASHICORP_VAULT_MISSING_VARIABLES[i]:1:1}
		DESC=${!HASHICORP_VAULT_MISSING_VARIABLES[i]:2:1}
		printf "${YELLOW}No value provided for '${NAME}'\n${COLOUR_OFF}"
		printf "$DESC\n"
		read -p "$(printf "${CYAN}Provide a value for '${NAME}': ${GREEN}")" $NAME
		printf "${COLOUR_OFF}"
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update Hashicorp Vault Variables

	set_hashicorp-vault
	clear

# Loop HASHICORP_VAULT_VARIABLES to display variables to be used for K3s deployment.

	TITLE="Variables to be using in K3s Deployment"
	print_title

	COUNT=${#HASHICORP_VAULT_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!HASHICORP_VAULT_VARIABLES[i]:0:1}
		VALUE=${!HASHICORP_VAULT_VARIABLES[i]:1:1}
		DESC=${!HASHICORP_VAULT_VARIABLES[i]:2:1}

		if [[ -z "${VALUE}" ]]; then
			echo "Name: ${NAME}"
			printf "Value: ${RED}${NAME} is undefined\n${COLOUR_OFF}"
			echo "Description: ${DESC}"
			printf ${WHITE}"=%.0s"	$(seq 1 ${BREAK})${COLOUR_OFF}
			printf "\n${COLOUR_OFF}"
		else
			printf "Name: ${CYAN}${NAME}\n${COLOUR_OFF}"
			printf "Value: ${GREEN}${VALUE}\n${COLOUR_OFF}"
			printf "Description: ${WHITE}${DESC}\n${COLOUR_OFF}"
			printf ${BLUE}"=%.0s"	$(seq 1 ${BREAK}) \n
			printf "\n${COLOUR_OFF}"
		fi
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

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

# Install Hashicorp Vault

	TITLE="Installing Hashicorp Vault in Namespace ${HASHICORP_VAULT_NAMESPACE}"
	print_title

	# https://developer.hashicorp.com/vault/docs/platform/k8s/helm
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo update
	helm install vault hashicorp/vault --namespace "$HASHICORP_VAULT_NAMESPACE" --create-namespace

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Hashicorp Vault to be Ready

	TITLE="Waiting for Hashicorp Vault to be Ready"
	print_title

	HASHICORP_VAULT_PODS=$(kubectl get pods -n ${HASHICORP_VAULT_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a HASHICORP_VAULT_PODS <<< "$HASHICORP_VAULT_PODS"

	# wait for there to be 3 pods in the Hashicorp Vault namespace
	while [ ${#HASHICORP_VAULT_PODS[@]} -ne 3 ]
	do
		HASHICORP_VAULT_PODS=$(kubectl get pods -n ${HASHICORP_VAULT_NAMESPACE} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a HASHICORP_VAULT_PODS <<< "$HASHICORP_VAULT_PODS"
	done

	# wait for those 3 pods to be in a ready state
	for i in "${HASHICORP_VAULT_PODS[@]}"; do
		kubectl wait -n ${HASHICORP_VAULT_NAMESPACE} --for=condition=Ready pod/${i} --timeout=${TIMEOUT}s
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update File 'hashicorp-vault-ingress.yaml'

	TITLE="Updating file hashicorp-vault-ingress.yaml with Hashicorp Vault Deployment Variables"
	print_title

	sed -i "s/HASHICORP_VAULT_NAMESPACE/$HASHICORP_VAULT_NAMESPACE/g" hashicorp-vault-ingress.yaml
	sed -i "s/HASHICORP_VAULT_SUBDOMAIN/$HASHICORP_VAULT_SUBDOMAIN/g" hashicorp-vault-ingress.yaml
	sed -i "s/DOMAIN/$DOMAIN/g" hashicorp-vault-ingress.yaml
	sed -i "s/CERT_ISSUER/$CERT_ISSUER/g" hashicorp-vault-ingress.yaml

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Create Hashicorp Vault Ingress

	TITLE="Creating and configuring Hashicorp Vault Ingress "
	print_title

	kubectl create -f hashicorp-vault-ingress.yaml

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Hashicorp Vault Certificate to be assigned

	TITLE="Waiting for Hashicorp Vault Certificate to be Ready"
	print_title

	# Query Certificates status in the Hashicorp Vault Namespace
	HASHICORP_VAULT_CERTIFICATE=$(kubectl get certificate -n ${HASHICORP_VAULT_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a HASHICORP_VAULT_CERTIFICATE <<< "$HASHICORP_VAULT_CERTIFICATE"

	# wait for there to be at least 1 certificate in the Hashicorp Vault namespace
	while [ ${#HASHICORP_VAULT_CERTIFICATE[@]} -ne 1 ]
	do
		HASHICORP_VAULT_CERTIFICATE=$(kubectl get certificate -n ${HASHICORP_VAULT_NAMESPACE} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a HASHICORP_VAULT_CERTIFICATE <<< "$HASHICORP_VAULT_CERTIFICATE"
	done

	# watit for certificates in the Hashicorp Vault namespace to be Ready
	for i in "${HASHICORP_VAULT_CERTIFICATE[@]}"; do
		kubectl wait -n ${HASHICORP_VAULT_NAMESPACE} --for=condition=Ready certificate/${i} --timeout=${TIMEOUT}s
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"



















# Update Grafana Password in 'kube-prometheus-stack-grafana' Secret

	# Generate Password for Grafana
	PASSWORD=$(cat /dev/random | tr -dc '[:alnum:]' | head -c 20 | base64)
	# This generates a new password if the current base64 encoded on contains a '/'
	while [[ $PASSWORD == *"/"* ]]
	do
		PASSWORD=$(cat /dev/random | tr -dc '[:alnum:]' | head -c 20 | base64)
	done

	# Update the 'kube-prometheus-stack-grafana' Secret with the New Password
	kubectl get secret kube-prometheus-stack-grafana -n ${HASHICORP_VAULT_NAMESPACE} -o json | jq ".data[\"admin-password\"]=\"${PASSWORD}\"" | kubectl apply -f -

	# Restart Grafana Container so that it uses the new Password (done up updating the evnironment variable 'DEPLOY_DATE' with the current date)
	kubectl set env deployment kube-prometheus-stack-grafana -n ${HASHICORP_VAULT_NAMESPACE} DEPLOY_DATE="$(date)"



# Deployment of Hashicorp Vault complete

	title="Hashicorp Vault Deployment Complete"
	print_title

	# Get Hashicorp Vault Grafana password from secrets
	KUBE_PROMETHEUS_STACK_USERNAME=$(kubectl get secret kube-prometheus-stack-grafana -n ${HASHICORP_VAULT_NAMESPACE} -o jsonpath="{.data.admin-user}" | base64 --decode)
	KUBE_PROMETHEUS_STACK_PASSWORD=$(kubectl get secret kube-prometheus-stack-grafana -n ${HASHICORP_VAULT_NAMESPACE} -o jsonpath="{.data.admin-password}" | base64 --decode)

	# Print Hashicorp Vault Details to screen for user
	printf "${GREEN}You can now access your Hashicorp Vault Grafana Dashboard at ${CYAN}https://${HASHICORP_VAULT_SUBDOMAIN}.${DOMAIN}\n${COLOUR_OFF}"
	printf "${GREEN}Username: ${CYAN}${KUBE_PROMETHEUS_STACK_USERNAME}\n${COLOUR_OFF}"
	printf "${GREEN}Password: ${CYAN}${KUBE_PROMETHEUS_STACK_PASSWORD}\n${COLOUR_OFF}"

	# Empty Password Variable
	KUBE_PROMETHEUS_STACK_PASSWORD=