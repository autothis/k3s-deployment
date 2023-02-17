#!/bin/bash

# Define variables for Wazuh deployment on K3s (uncomment lines, and populate variables - not required if using other methods of variable population).

	#WAZUH_NAMESPACE='' #This is the namespace that Wazuh will be deployed to.
	#WAZUH_SUBDOMAIN='' #This is the subdomain that will be used to serve your Wazuh dashboard.
	#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
    #WAZUH_STORAGE_CLASS='' #This is the Storage Class that will be used to assign a persistent volumes claim.
	#KUBE_CONFIG_DIR='' #This is the directory that your configuration files will be put in for future reference. e.g. '/kubeconfigs'

#Create Functions

	set_wazuhvariables () {

		# Define WAZUH_VARIABLE array containing required variables for K3s deployment
        WAZUH_VARIABLE_1=("WAZUH_NAMESPACE" "$WAZUH_NAMESPACE" "This is the namespace that Wazuh will be deployed to.")
		WAZUH_VARIABLE_2=("WAZUH_STORAGE_CLASS" "$WAZUH_STORAGE_CLASS" "This is the Storage Class that will be used to assign a persistent volumes claim.")
		WAZUH_VARIABLE_3=("WAZUH_SUBDOMAIN" "$WAZUH_SUBDOMAIN" "This is the subdomain that will be used to serve your Wazuh Dashboard. e.g. 'wazuh' will become wazuh.yourdomain.com")
		WAZUH_VARIABLE_4=("DOMAIN" "$DOMAIN" "This is the domain that your services will be available on e.g. 'yourdomain.com'")
		WAZUH_VARIABLE_5=("KUBE_CONFIG_DIR" "$KUBE_CONFIG_DIR" "This is the directory that your configuration files will be put in for future reference. e.g. '/kubeconfigs'")

		# Combine WAZUH_VARIABLE arrays int the WAZUH_VARIABLES array
		WAZUH_VARIABLES=(
			 WAZUH_VARIABLE_1[@]
			 WAZUH_VARIABLE_2[@]
			 WAZUH_VARIABLE_3[@]
			 WAZUH_VARIABLE_4[@]
			 WAZUH_VARIABLE_5[@]
		)
	}

	print_title () {

		printf ${YELLOW}"#%.0s"	$(seq 1 ${BREAK})
		printf "\n"
		printf "$TITLE \n"
		printf "#%.0s"	$(seq 1 ${BREAK})
		printf "\n"${COLOUR_OFF}

	}

	replace_variable () {

		sed -i -E "/${FIELD}/s/${FIELD}: .*/${FIELD}: ${NEW_VALUE}/" ${WAZUH_DEPLOY_PATH}/$FILE

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

	WAZUH_DEPLOY_PATH=$(pwd)

# Timeout in seconds

	TIMEOUT=300

# Break width '='

	BREAK=140

# Set Wazuh Variables

	set_wazuhvariables
	WAZUH_MISSING_VARIABLES=()
    WAZUH_STORAGE_CLASS=local-storage

# Missing Variables

	TITLE="Looking for missing Wazuh Deployment Variables"
	print_title

	# Loop WAZUH_VARIABLES looking for missing variables
	COUNT=${#WAZUH_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!WAZUH_VARIABLES[i]:0:1}
		VALUE=${!WAZUH_VARIABLES[i]:1:1}
		DESC=${!WAZUH_VARIABLES[i]:2:1}
		if [[ -z "${VALUE}" ]]; then
			echo "Name: ${NAME}"
			printf "Value: ${RED}${NAME} is undefined\n${COLOUR_OFF}"
			echo "Description: ${DESC}"
			printf ${WHITE}"=%.0s"	$(seq 1 ${BREAK})${COLOUR_OFF}
			printf "\n${COLOUR_OFF}"
			WAZUH_MISSING_VARIABLES+=( "WAZUH_VARIABLE_$(expr $i + 1)[@]" )
		fi
	done

	# Loop WAZUH_MISSING_VARIABLES to give user option to define any missing variables
	COUNT=${#WAZUH_MISSING_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!WAZUH_MISSING_VARIABLES[i]:0:1}
		VALUE=${!WAZUH_MISSING_VARIABLES[i]:1:1}
		DESC=${!WAZUH_MISSING_VARIABLES[i]:2:1}
		printf "${YELLOW}No value provided for '${NAME}'\n${COLOUR_OFF}"
           printf "$DESC\n"
           read -p "$(printf "${CYAN}Provide a value for '${NAME}': ${GREEN}")" $NAME
           printf "${COLOUR_OFF}"
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update Wazuh Variables

	set_wazuhvariables
	clear

# Loop WAZUH_VARIABLES to display variables to be used for Wazuh deployment.

	TITLE="Variables to be using in Wazuh Deployment"
	print_title

	COUNT=${#WAZUH_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!WAZUH_VARIABLES[i]:0:1}
		VALUE=${!WAZUH_VARIABLES[i]:1:1}
		DESC=${!WAZUH_VARIABLES[i]:2:1}

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

# Download Wazuh file from Github

	TITLE="Downloading Wazuh files from Github"
	print_title

	# Clone Stable Github Branch
	git clone --single-branch --branch stable https://github.com/wazuh/wazuh-kubernetes.git

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update Wazuh Config Files with Storage Class from WAZUH_STORAGE_CLASS

	TITLE="Update Storage Class in Wazuh Config Files"
	print_title

	# List of config files to update
    WAZUH_STORAGE_CLASS_CONFIG_FILES=(
        "wazuh-kubernetes/wazuh/indexer_stack/wazuh-indexer/cluster/indexer-sts.yaml"
        "wazuh-kubernetes/wazuh/wazuh_managers/wazuh-master-sts.yaml"
        "wazuh-kubernetes/wazuh/wazuh_managers/wazuh-worker-sts.yaml"
        )
        
    # Update the storageClassName field in each of the files stored in the WAZUH_STORAGE_CLASS_CONFIG_FILES array.
	for i in "${WAZUH_STORAGE_CLASS_UPDATE[@]}"; do
		sed -i -E "/storageClassName/s/storageClassName: .*/storageClassName: ${WAZUH_STORAGE_CLASS}" ${WAZUH_DEPLOY_PATH}/$i
        printf "Updating storageClassName in config file: ${WAZUH_DEPLOY_PATH}/${i}\n${COLOUR_OFF}"
	done

    # Comment out the line containing 'storage-class.yaml' in 'kustomization.yaml' file.
    sed -i "s/- storage-class.yaml/#- storage-class.yaml/g" ${WAZUH_DEPLOY_PATH}/wazuh-kubernetes/envs/local-env/kustomization.yml
    printf "Commenting out 'storage-class.yaml' in config file: ${WAZUH_DEPLOY_PATH}/wazuh-kubernetes/envs/local-env/kustomization.yml\n${COLOUR_OFF}"

    # Comment out the line containing 'storage-class.yaml' in 'kustomization.yaml' file.
    sed -i "s/- base\/storage-class.yaml/#- base\/storage-class.yaml/g" ${WAZUH_DEPLOY_PATH}/wazuh-kubernetes/wazuh/kustomization.yml
    printf "Commenting out 'storage-class.yaml' in config file: ${WAZUH_DEPLOY_PATH}/wazuh-kubernetes/wazuh/kustomization.yml\n${COLOUR_OFF}"

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update Hardcoded Credentials in Wazuh Config Files

	TITLE="Updating Wazuh Credentials in Wazuh Files"
	print_title

	# Passwords to be generate (Field to Update, Character Count, File)
	WAZUH_CRED_VARIABLE_1=("password" "12" "wazuh-kubernetes/wazuh/secrets/dashboard-cred-secret.yaml")
	WAZUH_CRED_VARIABLE_2=("password" "12" "wazuh-kubernetes/wazuh/secrets/indexer-cred-secret.yaml")
	WAZUH_CRED_VARIABLE_3=("password" "16" "wazuh-kubernetes/wazuh/secrets/wazuh-api-cred-secret.yaml")
	WAZUH_CRED_VARIABLE_4=("authd.pass" "12" "wazuh-kubernetes/wazuh/secrets/wazuh-authd-pass-secret.yaml")
	WAZUH_CRED_VARIABLE_5=("key" "32" "wazuh-kubernetes/wazuh/secrets/wazuh-cluster-key-secret.yaml")

	# Combine WAZUH_VARIABLE arrays int the WAZUH_CREDENTIAL_CONFIG_FILES array
	WAZUH_CREDENTIAL_CONFIG_FILES=(
		WAZUH_CRED_VARIABLE_1[@]
		WAZUH_CRED_VARIABLE_2[@]
		WAZUH_CRED_VARIABLE_3[@]
		WAZUH_CRED_VARIABLE_4[@]
		WAZUH_CRED_VARIABLE_5[@]
	)

	# Loop through WAZUH_CREDENTIAL_CONFIG_FILES array and update password
	COUNT=${#WAZUH_CREDENTIAL_CONFIG_FILES[@]}
	for ((i=0; i<$COUNT; i++)); do
		FIELD=${!WAZUH_CREDENTIAL_CONFIG_FILES[i]:0:1}
		NEW_VALUE_LENGTH=${!WAZUH_CREDENTIAL_CONFIG_FILES[i]:1:1}
		FILE=${!WAZUH_CREDENTIAL_CONFIG_FILES[i]:2:1}
		NEW_VALUE=$(openssl rand -base64 ${NEW_VALUE_LENGTH} | base64)

		echo $FILE
		echo $NEW_VALUE

		# This generates a new password if the current base64 encoded on contains a '/'
		while [[ $NEW_VALUE == *"/"* ]]
		do
			NEW_VALUE=$(openssl rand -base64 ${NEW_VALUE_LENGTH} | base64)
		done

		# Call function to replace passwords in files
		replace_password
	done

# Update Wazuh Namespace in Configuration Files

	TITLE="Updating Wazuh Namespace in Wazuh Files"
	print_title
	
	WAZUH_NAMESPACE_CONFIG_FILES=(
		"wazuh-kubernetes/envs/local-envwazuh-resources.yaml"
		"wazuh-kubernetes/envs/local-envindexer-resources.yaml"
		"wazuh-kubernetes/wazuh/secrets/wazuh-api-cred-secret.yaml"
		"wazuh-kubernetes/wazuh/secrets/wazuh-authd-pass-secret.yaml"
		"wazuh-kubernetes/wazuh/secrets/wazuh-cluster-key-secret.yaml"
		"wazuh-kubernetes/wazuh/wazuh_managers/wazuh-cluster-svc.yaml"
		"wazuh-kubernetes/wazuh/wazuh_managers/wazuh-master-sts.yaml"
		"wazuh-kubernetes/wazuh/wazuh_managers/wazuh-master-svc.yaml"
		"wazuh-kubernetes/wazuh/wazuh_managers/wazuh-workers-svc.yaml"
		"wazuh-kubernetes/wazuh/wazuh_managers/wazuh-worker-sts.yaml"
		"wazuh-kubernetes/wazuh/indexer_stack/wazuh-dashboard/dashboard-deploy.yaml"
		"wazuh-kubernetes/wazuh/indexer_stack/wazuh-dashboard/dashboard-svc.yaml"
		"wazuh-kubernetes/wazuh/indexer_stack/wazuh-indexer/indexer-svc.yaml"
		"wazuh-kubernetes/wazuh/indexer_stack/wazuh-indexer/cluster/indexer-api-svc.yaml"
		"wazuh-kubernetes/wazuh/indexer_stack/wazuh-indexer/cluster/indexer-sts.yaml"
		"wazuh-kubernetes/wazuh/base/wazuh-ns.yaml"
	)

	# Loop through WAZUH_CREDENTIAL_CONFIG_FILES array and update password
	COUNT=${#WAZUH_NAMESPACE_CONFIG_FILES[@]}
	for ((i=0; i<$COUNT; i++)); do
		FIELD="namespace"
		FILE=${i}
		NEW_VALUE=${WAZUH_NAMESPACE}

		# Call function to replace passwords in files
		replace_password
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Generate Internal Wazuh Certificates

	TITLE="Generating Wazuh Internal Certificates with Cert-Manager"
	print_title
	
	# Execute certificate generation scripts provided by Wazuh
	${WAZUH_DEPLOY_PATH}/wazuh-kubernetes/wazuh/certs/dashboard_http/generate_certs.sh
	${WAZUH_DEPLOY_PATH}/wazuh-kubernetes/wazuh/certs/indexer_cluster/generate_certs.sh

	# Future Improvement - Use Cert-Manager to generate and manage internal certificates
	# Create Internal Cert Issuer
		# https://phoenixnap.com/kb/kubernetes-ssl-certificates
	# Create Dashboard Certificate normally created by generate_certs.sh
		# wazuh-kubernetes/wazuh/certs/dashboard_http/generate_certs.sh
	# Create Indexer Certificate normally created by generate_certs.sh
		# wazuh-kubernetes/wazuh/certs/indexer_cluster/generate_certs.sh
	# Update in Wazuh files:
		# wazuh/indexer_stack/wazuh-indexer/cluster/indexer-sts.yaml
		# wazuh/indexer_stack/wazuh-dashboard/dashboard-deploy.yaml
		# wazuh/indexer_stack/wazuh-indexer/indexer_conf/opensearch.yml
		# wazuh/wazuh_managers/wazuh-worker-sts.yaml
		# wazuh/wazuh_managers/wazuh-master-sts.yaml
		# wazuh/indexer_stack/wazuh-dashboard/dashboard_conf/opensearch_dashboards.yml

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Deploy Wazuh

	TITLE="Deploying Wazuh with Kustomize"
	print_title
	
	kubectl apply -k envs/local-env/

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Configure Wazuh Ingress

	TITLE="Updating file wazuh-ingress.yaml with Wazuh Deployment Variables"
	print_title

	sed -i "s/DASHBOARD_SUBDOMAIN/$DASHBOARD_SUBDOMAIN/g" ${WAZUH_DEPLOY_PATH}/wazuh-ingress.yaml
	sed -i "s/DOMAIN/$DOMAIN/g" ${WAZUH_DEPLOY_PATH}/wazuh-ingress.yaml

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for Certificates to be assigned

	TITLE="Waiting for Wazuh Dashboard Certificates to be Ready"
	print_title

	# Query Certificates status in the Wazuh Namespace
	WAZUH_CERTIFICATES=$(kubectl get certificate -n ${WAZUH_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a WAZUH_CERTIFICATES <<< "$WAZUH_CERTIFICATES"
	for i in "${WAZUH_CERTIFICATES[@]}"; do
		kubectl wait -n ${WAZUH_NAMESPACE} --for=condition=Ready certificate/${i} --timeout=${TIMEOUT}s
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Deployment of Wazuh complete

	TITLE="Wazuh Deployment Complete"
	print_title

	# Get Wazuh username and password from secrets
	WAZUH_USERNAME=$(kubectl get secret indexer-cred -n ${WAZUH_NAMESPACE} -o jsonpath="{.data.username}" | base64 --decode)
	WAZUH_PASSWORD=$(kubectl get secret indexer-cred -n ${WAZUH_NAMESPACE} -o jsonpath="{.data.password}" | base64 --decode)
	WAZUH_ENROLL=$(kubectl get secret wazuh-authd-pass -n ${WAZUH_NAMESPACE} -o jsonpath="{.data.authd\.pass}" | base64 --decode)

	# Print Wazuh Details to screen for user
	printf "${GREEN}You can now access your Wazuh Dashboard at ${CYAN}https://${WAZUH_SUBDOMAIN}.${DOMAIN}\n${COLOUR_OFF}"
	printf "${GREEN}Username: ${CYAN}${WAZUH_USERNAME}\n${COLOUR_OFF}"
	printf "${GREEN}Password: ${CYAN}${WAZUH_PASSWORD}\n${COLOUR_OFF}"

	printf "${GREEN}You can also now enroll endpoints with Wazuh using the password: ${CYAN}${WAZUH_PASSWORD}\n${COLOUR_OFF}"

	# Empty Password Variable
	WAZUH_PASSWORD=
	WAZUH_ENROLL=