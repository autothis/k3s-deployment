#!/bin/bash

# Define variables for Kube Prometheus Stack deployment on K3s (uncomment lines, and populate variables - not required if using other methods of variable population).

	#KUBE_PROMETHEUS_STACK_NAMESPACE='' #This is the namespace that Kube Prometheus Stack will be deployed to e.g. 'monitoring'.
	#KUBE_PROMETHEUS_STACK_SUBDOMAIN='' #This is the subdomain that will be used to serve your Kube Prometheus Stack dashboard e.g. 'kubemonitor'.
	#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
	#CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Kube Prometheus Stack e.g. 'prod-issuer' or 'selfsigned-issuer'.

#Create Functions

	set_kube-prometheus-stack-variables () {

		# Define KUBE_PROMETHEUS_STACK_VARIABLE array containing required variables for K3s deployment
		KUBE_PROMETHEUS_STACK_VARIABLE_1=("KUBE_PROMETHEUS_STACK_NAMESPACE" "$KUBE_PROMETHEUS_STACK_NAMESPACE" "This is the namespace that Kube Prometheus Stack will be deployed to e.g. 'monitoring'.")
		KUBE_PROMETHEUS_STACK_VARIABLE_2=("KUBE_PROMETHEUS_STACK_SUBDOMAIN" "$KUBE_PROMETHEUS_STACK_SUBDOMAIN" "This is the subdomain that will be used to serve your Kube Prometheus Stack Dashboard. e.g. 'kubemonitor' will become 'kubemonitor.yourdomain.com'.")
		KUBE_PROMETHEUS_STACK_VARIABLE_3=("DOMAIN" "$DOMAIN" "This is the domain that your services will be available on e.g. 'yourdomain.com'.")
		KUBE_PROMETHEUS_STACK_VARIABLE_4=("CERT_ISSUER" "$CERT_ISSUER" "This is the certificate issuer that will be used to issue a certificate for the Kube Prometheus Stack e.g. 'prod-issuer' or 'selfsigned-issuer'.")

	 # Combine KUBE_PROMETHEUS_STACK_VARIABLE arrays int the KUBE_PROMETHEUS_STACK_VARIABLES array
	 KUBE_PROMETHEUS_STACK_VARIABLES=(
		KUBE_PROMETHEUS_STACK_VARIABLE_1[@]
		KUBE_PROMETHEUS_STACK_VARIABLE_2[@]
		KUBE_PROMETHEUS_STACK_VARIABLE_3[@]
		KUBE_PROMETHEUS_STACK_VARIABLE_4[@]
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

# Set Kube Prometheus Stack Variables

	set_kube-prometheus-stack-variables
	KUBE_PROMETHEUS_STACK_MISSING_VARIABLES=()

# Missing Variables

	TITLE="Looking for missing Kube Prometheus Stack Deployment Variables"
	print_title

	# Loop KUBE_PROMETHEUS_STACK_VARIABLES looking for missing variables
	COUNT=${#KUBE_PROMETHEUS_STACK_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!KUBE_PROMETHEUS_STACK_VARIABLES[i]:0:1}
		VALUE=${!KUBE_PROMETHEUS_STACK_VARIABLES[i]:1:1}
		DESC=${!KUBE_PROMETHEUS_STACK_VARIABLES[i]:2:1}
		if [[ -z "${VALUE}" ]]; then
			echo "Name: ${NAME}"
			printf "Value: ${RED}${NAME} is undefined\n${COLOUR_OFF}"
			echo "Description: ${DESC}"
			printf ${WHITE}"=%.0s"	$(seq 1 ${BREAK})${COLOUR_OFF}
			printf "\n${COLOUR_OFF}"
			KUBE_PROMETHEUS_STACK_MISSING_VARIABLES+=( "KUBE_PROMETHEUS_STACK_VARIABLE_$(expr $i + 1)[@]" )
		fi
	done

	# Loop KUBE_PROMETHEUS_STACK_MISSING_VARIABLES to give user option to define any missing variables
	COUNT=${#KUBE_PROMETHEUS_STACK_MISSING_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!KUBE_PROMETHEUS_STACK_MISSING_VARIABLES[i]:0:1}
		VALUE=${!KUBE_PROMETHEUS_STACK_MISSING_VARIABLES[i]:1:1}
		DESC=${!KUBE_PROMETHEUS_STACK_MISSING_VARIABLES[i]:2:1}
		printf "${YELLOW}No value provided for '${NAME}'\n${COLOUR_OFF}"
		printf "$DESC\n"
		read -p "$(printf "${CYAN}Provide a value for '${NAME}': ${GREEN}")" $NAME
		printf "${COLOUR_OFF}"
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update Kube Prometheus Stack Variables

	set_kube-prometheus-stack-variables
	clear

# Loop KUBE_PROMETHEUS_STACK_VARIABLES to display variables to be used for K3s deployment.

	TITLE="Variables to be using in K3s Deployment"
	print_title

	COUNT=${#KUBE_PROMETHEUS_STACK_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!KUBE_PROMETHEUS_STACK_VARIABLES[i]:0:1}
		VALUE=${!KUBE_PROMETHEUS_STACK_VARIABLES[i]:1:1}
		DESC=${!KUBE_PROMETHEUS_STACK_VARIABLES[i]:2:1}

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

# Install Kube Prometheus Stack

	TITLE="Installing Kube Prometheus Stack in Namespace ${KUBE_PROMETHEUS_STACK_NAMESPACE}"
	print_title

	# https://prometheus-community.github.io/helm-charts
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install kube-prometheus-stack -f kube-prometheus-stack-custom-values.yaml prometheus-community/kube-prometheus-stack --namespace "$KUBE_PROMETHEUS_STACK_NAMESPACE" --create-namespace

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Kube Prometheus Stack to be Ready

	TITLE="Waiting for Kube Prometheus Stack to be Ready"
	print_title

	KUBE_PROMETHEUS_STACK_PODS=$(kubectl get pods -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a KUBE_PROMETHEUS_STACK_PODS <<< "$KUBE_PROMETHEUS_STACK_PODS"

	# wait for there to be 6 pods in the Kube Prometheus Stack namespace
	while [ ${#KUBE_PROMETHEUS_STACK_PODS[@]} -ne 6 ]
	do
		KUBE_PROMETHEUS_STACK_PODS=$(kubectl get pods -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a KUBE_PROMETHEUS_STACK_PODS <<< "$KUBE_PROMETHEUS_STACK_PODS"
	done

	# wait for those 6 pods to be in a ready state
	for i in "${KUBE_PROMETHEUS_STACK_PODS[@]}"; do
		kubectl wait -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} --for=condition=Ready pod/${i} --timeout=${TIMEOUT}s
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update File 'kube-prometheus-stack-ingress.yaml'

	TITLE="Updating file kube-prometheus-stack-ingress.yaml with Kube Prometheus Stack Deployment Variables"
	print_title

	sed -i "s/KUBE_PROMETHEUS_STACK_NAMESPACE/$KUBE_PROMETHEUS_STACK_NAMESPACE/g" kube-prometheus-stack-ingress.yaml
	sed -i "s/KUBE_PROMETHEUS_STACK_SUBDOMAIN/$KUBE_PROMETHEUS_STACK_SUBDOMAIN/g" kube-prometheus-stack-ingress.yaml
	sed -i "s/DOMAIN/$DOMAIN/g" kube-prometheus-stack-ingress.yaml
	sed -i "s/CERT_ISSUER/$CERT_ISSUER/g" kube-prometheus-stack-ingress.yaml

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
	kubectl get secret kube-prometheus-stack-grafana -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} -o json | jq ".data[\"admin-password\"]=\"${PASSWORD}\"" | kubectl apply -f -

	# Restart Grafana Container so that it uses the new Password (done up updating the evnironment variable 'DEPLOY_DATE' with the current date)
	kubectl set env deployment kube-prometheus-stack-grafana -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} DEPLOY_DATE="$(date)"

# Create Kube Prometheus Stack Grafana Ingress

	TITLE="Creating and configuring Kube Prometheus Stack Grafana Ingress "
	print_title

	kubectl create -f kube-prometheus-stack-ingress.yaml

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Kube Prometheus Stack Certificate to be assigned

	TITLE="Waiting for Kube Prometheus Stack Certificate to be Ready"
	print_title

	# Query Certificates status in the Kube Prometheus Stack Namespace
	KUBE_PROMETHEUS_STACK_CERTIFICATE=$(kubectl get certificate -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a KUBE_PROMETHEUS_STACK_CERTIFICATE <<< "$KUBE_PROMETHEUS_STACK_CERTIFICATE"

	# wait for there to be at least 1 certificate in the Kube Prometheus Stack namespace
	while [ ${#KUBE_PROMETHEUS_STACK_CERTIFICATE[@]} -ne 1 ]
	do
		KUBE_PROMETHEUS_STACK_CERTIFICATE=$(kubectl get certificate -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a KUBE_PROMETHEUS_STACK_CERTIFICATE <<< "$KUBE_PROMETHEUS_STACK_CERTIFICATE"
	done

	# watit for certificates in the Kube Prometheus Stack namespace to be Ready
	for i in "${KUBE_PROMETHEUS_STACK_CERTIFICATE[@]}"; do
		kubectl wait -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} --for=condition=Ready certificate/${i} --timeout=${TIMEOUT}s
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Deployment of Kube Prometheus Stack complete

	title="Kube Prometheus Stack Deployment Complete"
	print_title

	# Get Kube Prometheus Stack Grafana password from secrets
	KUBE_PROMETHEUS_STACK_USERNAME=$(kubectl get secret kube-prometheus-stack-grafana -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} -o jsonpath="{.data.admin-user}" | base64 --decode)
	KUBE_PROMETHEUS_STACK_PASSWORD=$(kubectl get secret kube-prometheus-stack-grafana -n ${KUBE_PROMETHEUS_STACK_NAMESPACE} -o jsonpath="{.data.admin-password}" | base64 --decode)

	# Print Kube Prometheus Stack Details to screen for user
	printf "${GREEN}You can now access your Kube Prometheus Stack Grafana Dashboard at ${CYAN}https://${KUBE_PROMETHEUS_STACK_SUBDOMAIN}.${DOMAIN}\n${COLOUR_OFF}"
	printf "${GREEN}Username: ${CYAN}${KUBE_PROMETHEUS_STACK_USERNAME}\n${COLOUR_OFF}"
	printf "${GREEN}Password: ${CYAN}${KUBE_PROMETHEUS_STACK_PASSWORD}\n${COLOUR_OFF}"

	# Empty Password Variable
	KUBE_PROMETHEUS_STACK_PASSWORD=