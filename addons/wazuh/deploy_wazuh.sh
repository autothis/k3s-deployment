#!/bin/bash

# Define variables for AWX deployment on K3s (uncomment lines, and populate variables - not required if using other methods of variable population).

	#WAZUH_NAMESPACE='' #This is the namespace that AWX will be deployed to.
	#WAZUH_SUBDOMAIN='' #This is the subdomain that will be used to serve your AWX dashboard.
	#DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
    #WAZUH_STORAGE_CLASS='' #This is the Storage Class that will be used to assign a persistent volumes claim.

#Create Functions

	set_wazuhvariables () {

		# Define WAZUH_VARIABLE array containing required variables for K3s deployment
        WAZUH_VARIABLE_1=("WAZUH_NAMESPACE" "$WAZUH_NAMESPACE" "This is the namespace that AWX will be deployed to.")
		WAZUH_VARIABLE_2=("WAZUH_SUBDOMAIN" "$WAZUH_SUBDOMAIN" "This is the subdomain that will be used to serve your AWX Dashboard. e.g. 'awx' will become awx.yourdomain.com")
		WAZUH_VARIABLE_3=("DOMAIN" "$DOMAIN" "This is the domain that your services will be available on e.g. 'yourdomain.com'")
        WAZUH_VARIABLE_4=("WAZUH_STORAGE_CLASS" "$WAZUH_STORAGE_CLASS" "This is the Storage Class that will be used to assign a persistent volumes claim.")

	 # Combine WAZUH_VARIABLE arrays int the WAZUH_VARIABLES array
	 WAZUH_VARIABLES=(
		 WAZUH_VARIABLE_1[@]
		 WAZUH_VARIABLE_2[@]
		 WAZUH_VARIABLE_3[@]
		 WAZUH_VARIABLE_4[@]
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

# Loop WAZUH_VARIABLES to display variables to be used for K3s deployment.

	TITLE="Variables to be using in K3s Deployment"
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

# Update Wazuh Config Files with Storage Class from WAZUH_STORAGE_CLASS

	TITLE="Update Storage Class in Wazuh Config Files"
	print_title

	# List of config files to update
    WAZUH_STORAGE_CLASS_CONFIG_FILES=(
        "wazuh/indexer_stack/wazuh-indexer/cluster/indexer-sts.yaml"
        "wazuh/wazuh_managers/wazuh-master-sts.yaml"
        "wazuh/wazuh_managers/wazuh-worker-sts.yaml"
        )
        
    # Update the storageClassName field in each of the files stored in the WAZUH_STORAGE_CLASS_CONFIG_FILES array.
	for i in "${WAZUH_STORAGE_CLASS_UPDATE[@]}"; do
		sed -i -E "/storageClassName/s/storageClassName: .*/storageClassName: ${WAZUH_STORAGE_CLASS}" ${WAZUH_DEPLOY_PATH}/$i
        printf "Updating storageClassName in config file: ${WAZUH_DEPLOY_PATH}/${i}\n${COLOUR_OFF}"
	done

    # Comment out the line containing 'storage-class.yaml' in 'kustomization.yaml' file.
    sed -i "s/- storage-class.yaml/#- storage-class.yaml/g" ${WAZUH_DEPLOY_PATH}/envs/local-env/kustomization.yml
    printf "Commenting out 'storage-class.yaml' in config file: ${WAZUH_DEPLOY_PATH}/${i}\n${COLOUR_OFF}"

    # Comment out the line containing 'storage-class.yaml' in 'kustomization.yaml' file.
    sed -i "s/- base\/storage-class.yaml/#- base\/storage-class.yaml/g" ${WAZUH_DEPLOY_PATH}/$i
    printf "Commenting out 'storage-class.yaml' in config file: ${WAZUH_DEPLOY_PATH}/${i}\n${COLOUR_OFF}"

	printf "${GREEN}Done\n${COLOUR_OFF}"