#!/bin/bash

# Define variables for AWX deployment on K3s (uncomment lines, and populate variables - not required if using other methods of variable population).

	#AWX_NAMESPACE='' #This is the namespace that AWX will be deployed to.
	#AWX_VERSION='' #This is the version of AWX to be deployed, this variable will automatically populated.
	#AWX_SUBDOMAIN='' #This is the subdomain that will be used to serve your AWX dashboard.
	#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
	#CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Kubernetes Dashboard e.g. 'prod-issuer' or 'selfsigned-issuer'.

#Create Functions

	set_awxvariables () {

		# Define AWX_VARIABLE array containing required variables for K3s deployment
		AWX_VARIABLE_1=("AWX_NAMESPACE" "$AWX_NAMESPACE" "This is the namespace that AWX will be deployed to.")
		AWX_VARIABLE_2=("AWX_VERSION" "$AWX_VERSION" "This is the version of AWX to be deployed, this variable will automatically populated.")
		AWX_VARIABLE_3=("AWX_SUBDOMAIN" "$AWX_SUBDOMAIN" "This is the subdomain that will be used to serve your AWX Dashboard. e.g. 'awx' will become awx.yourdomain.com")
		AWX_VARIABLE_4=("DOMAIN" "$DOMAIN" "This is the domain that your services will be available on e.g. 'yourdomain.com'")
		AWX_VARIABLE_5=("CERT_ISSUER" "$CERT_ISSUER" "This is the certificate issuer that will be used to issue a certificate for the AWX Dashboard e.g. 'prod-issuer' or 'selfsigned-issuer'")

	 # Combine AWX_VARIABLE arrays int the AWX_VARIABLES array
	 AWX_VARIABLES=(
		 AWX_VARIABLE_1[@]
		 AWX_VARIABLE_2[@]
		 AWX_VARIABLE_3[@]
		 AWX_VARIABLE_4[@]
		 AWX_VARIABLE_5[@]
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

# Get latest AWX Version

	TITLE="Getting latest AWX Version Number"
	print_title

	# Query AWX Github page for latest AWX version number
	URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ansible/awx-operator/releases/latest)
	IFS='/ ' read -r -a AWX_LATEST_VERSION <<< "$URL"
	AWX_VERSION=${AWX_LATEST_VERSION[-1]}

	printf "Latest AWX version is: ${CYAN}${AWX_VERSION}\n${COLOUR_OFF}"

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Set AWX Variables

	set_awxvariables
	AWX_MISSING_VARIABLES=()

# Missing Variables

	TITLE="Looking for missing AWX Deployment Variables"
	print_title

	# Loop AWX_VARIABLES looking for missing variables
	COUNT=${#AWX_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!AWX_VARIABLES[i]:0:1}
		VALUE=${!AWX_VARIABLES[i]:1:1}
		DESC=${!AWX_VARIABLES[i]:2:1}
		if [[ -z "${VALUE}" ]]; then
			echo "Name: ${NAME}"
			printf "Value: ${RED}${NAME} is undefined\n${COLOUR_OFF}"
			echo "Description: ${DESC}"
			printf ${WHITE}"=%.0s"	$(seq 1 ${BREAK})${COLOUR_OFF}
			printf "\n${COLOUR_OFF}"
			AWX_MISSING_VARIABLES+=( "AWX_VARIABLE_$(expr $i + 1)[@]" )
		fi
	done

	# Loop AWX_MISSING_VARIABLES to give user option to define any missing variables
	COUNT=${#AWX_MISSING_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!AWX_MISSING_VARIABLES[i]:0:1}
		VALUE=${!AWX_MISSING_VARIABLES[i]:1:1}
		DESC=${!AWX_MISSING_VARIABLES[i]:2:1}
		printf "${YELLOW}No value provided for '${NAME}'\n${COLOUR_OFF}"
           printf "$DESC\n"
           read -p "$(printf "${CYAN}Provide a value for '${NAME}': ${GREEN}")" $NAME
           printf "${COLOUR_OFF}"
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update AWX Variables

	set_awxvariables
	clear

# Loop AWX_VARIABLES to display variables to be used for K3s deployment.

	TITLE="Variables to be using in K3s Deployment"
	print_title

	COUNT=${#AWX_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!AWX_VARIABLES[i]:0:1}
		VALUE=${!AWX_VARIABLES[i]:1:1}
		DESC=${!AWX_VARIABLES[i]:2:1}

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

# Update Version Number in 'kustomization.yaml' file

	TITLE="Updating Version Number in 'kustomization.yaml' file"
	print_title
	
	# Update 'kustomization.yaml' file with the latest AWX version number
	sed -i -E "/ref/s/ref=.*/ref=${AWX_VERSION}/" kustomization.yaml
	sed -i -E "/newTag/s/newTag: .*/newTag: ${AWX_VERSION}/" kustomization.yaml
	sed -i "s/AWX_NAMESPACE/$AWX_NAMESPACE/g" kustomization.yaml

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Create 'awx.yaml' file.

	TITLE="Creating 'awx.yaml' file"
	print_title

	# Update Variables in 'awx.yaml' file
	sed -i "s/AWX_NAMESPACE/$AWX_NAMESPACE/g" awx.yaml
	sed -i "s/AWX_SUBDOMAIN/$AWX_SUBDOMAIN/g" awx.yaml
	sed -i "s/DOMAIN/$DOMAIN/g" awx.yaml
	sed -i "s/CERT_ISSUER/$CERT_ISSUER/g" awx.yaml

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Deploy AWX Operator

	TITLE="Deploying AWX Operator"
	print_title

	# Build Kustomize file, and apply to Kubernetes to create replacement Operator Pods
	kustomize build . | kubectl apply -f -

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for AWX Operator to be Ready

	TITLE="Waiting for AWX Operator to be Ready"
	print_title

	# Get Pods in AWX namespace
	AWX_PODS=$(kubectl get pods -n ${AWX_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a AWX_PODS <<< "$AWX_PODS"

	# Wait for those pods to be in a ready state
	for i in "${AWX_PODS[@]}"; do
		kubectl wait -n ${AWX_NAMESPACE} --for=condition=Ready pod/${i} --timeout=${TIMEOUT}s
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Deploy AWX

	TITLE="Deploying AWX"
	print_title

	# Uncomment 'awx.yaml' resource in 'kustomization.yaml' file
	sed -i "s/#-/-/g" kustomization.yaml

	# Build Kustomize file, and apply to Kubernetes to create replacement Operator Pods
	kustomize build . | kubectl apply -f -

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for AWX to be Ready

	TITLE="Waiting for AWX to be Ready"
	print_title

	# Get Pods in the AWX Namespace
	AWX_PODS=$(kubectl get pods -n ${AWX_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a AWX_PODS <<< "$AWX_PODS"

	# Wait for there to be 3 pods in the AWX namespace
	while [ ${#AWX_PODS[@]} -ne 3 ]
	do
		AWX_PODS=$(kubectl get pods -n ${AWX_NAMESPACE} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a AWX_PODS <<< "$AWX_PODS"
	done
	
	# Wait for those 3 pods to be in a ready state
	for i in "${AWX_PODS[@]}"; do
		kubectl wait -n ${AWX_NAMESPACE} --for=condition=Ready pod/${i} --timeout=${TIMEOUT}s
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Certificate to be assigned

	TITLE="Waiting for AWX Certificate to be Ready"
	print_title

	# Query Certificates status in the AWX Namespace
	AWX_CERTIFICATE=$(kubectl get certificate -n ${AWX_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a AWX_CERTIFICATE <<< "$AWX_CERTIFICATE"
	for i in "${AWX_CERTIFICATE[@]}"; do
		kubectl wait -n ${AWX_NAMESPACE} --for=condition=Ready certificate/${i} --timeout=${TIMEOUT}s
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Deployment of AWX complete


	title="AWX Deployment Complete"
	print_title

	# Get AWX password from secrets
	AWX_PASSWORD=$(kubectl get secret awx-admin-password -n ${AWX_NAMESPACE} -o jsonpath="{.data.password}" | base64 --decode)
	
	# Print AWX Details to screen for user
	printf "${GREEN}You can now access your AWX Dashboard at ${CYAN}https://${AWX_SUBDOMAIN}.${DOMAIN}\n${COLOUR_OFF}"
	printf "${GREEN}Username: ${CYAN}super\n${COLOUR_OFF}"
	printf "${GREEN}Password: ${CYAN}${AWX_PASSWORD}\n${COLOUR_OFF}"

	printf "${RED}NOTE: You may see some errors on the POSTGRES pod, or the 'awx-web' and 'awx-task' containers in the AWX pod.\n${COLOUR_OFF}"
	printf "${RED}Be patient, give the system at least 10mins before you start deleting or restarting pods.\n${COLOUR_OFF}"

	# Empty Password Variable
	AWX_PASSWORD=
