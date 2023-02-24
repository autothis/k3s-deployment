#!/bin/bash

# Define variables for Nautobot deployment on K3s (uncomment lines, and populate variables - not required if using other methods of variable population).


    #NAUTO_NAMESPACE='' #This is the namespace that Nautobot will be deployed to.
    #NAUTO_SUBDOMAIN='' #This is the subdomain that will be used to serve your Nautobot dashboard.
	#NAUTO_SQL_PW='' #this is the paasword that the Nautobot postgres user will have.
    #NAUTO_REDIS_PW='' #this is the paasword that the Nautobot redis will have.
	#NAUTO_RELEASE_NAME='' #this is the release name Nautobot will have. Commonly just 'nautobot'.
    #DOMAIN='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.
	#CERT_ISSUER='prod-issuer' #This is the certificate issuer that will be used to issue a certificate for the Kubernetes Dashboard e.g. 'prod-issuer' or 'selfsigned-issuer'.

#Create Functions

	set_nautovariables () {

		# Define NAUTO_VARIABLE array containing required variables for K3s deployment
		NAUTO_VARIABLE_1=("NAUTO_NAMESPACE" "$NAUTO_NAMESPACE" "This is the namespace that nauto will be deployed to.")
		NAUTO_VARIABLE_2=("NAUTO_SUBDOMAIN" "$NAUTO_SUBDOMAIN" "This is the subdomain that will be used to serve your nauto Dashboard. e.g. 'nauto' will become nauto.yourdomain.com")
		NAUTO_VARIABLE_3=("NAUTO_SQL_PW" "$NAUTO_SQL_PW" "This is the paasword that the Nautobot postgres user will have.")
        NAUTO_VARIABLE_4=("NAUTO_REDIS_PW" "$NAUTO_REDIS_PW" "This is the paasword that the Nautobot redis will have.")
		NAUTO_VARIABLE_5=("NAUTO_RELEASE_NAME" "$NAUTO_RELEASE_NAME" "This is the release name Nautobot will have. Commonly just 'nautobot'.")
        NAUTO_VARIABLE_6=("DOMAIN" "$DOMAIN" "This is the domain that your services will be available on e.g. 'yourdomain.com'")
		NAUTO_VARIABLE_7=("CERT_ISSUER" "$CERT_ISSUER" "This is the certificate issuer that will be used to issue a certificate for the Kubernetes Dashboard e.g. 'prod-issuer' or 'selfsigned-issuer'")

	 # Combine NAUTO_VARIABLE arrays int the NAUTO_VARIABLES array
	 NAUTO_VARIABLES=(
		 NAUTO_VARIABLE_1[@]
		 NAUTO_VARIABLE_2[@]
		 NAUTO_VARIABLE_3[@]
		 NAUTO_VARIABLE_4[@]
		 NAUTO_VARIABLE_5[@]
		 NAUTO_VARIABLE_6[@]
	 )
	}

	print_title () {

		printf ${YELLOW}"#%.0s"	$(seq 1 100)
		printf "\n"
		printf "$title \n"
		printf "#%.0s"	$(seq 1 100)
		printf "\n"${Color_Off}

	}

#Define Output Colours

	# Reset
	Color_Off='\033[0m'			 # Text Reset

	# Regular Colors
	BLACK='\033[0;30m'				# Black
	RED='\033[0;31m'					# Red
	GREEN='\033[0;32m'				# Green
	YELLOW='\033[0;33m'			 # Yellow
	BLUE='\033[0;34m'				 # Blue
	PURPLE='\033[0;35m'			 # Purple
	CYAN='\033[0;36m'				 # Cyan
	WHITE='\033[0;37m'				# White

# Get current working directory

  K3S_DEPLOY_PATH=$(pwd)

# Timeout in seconds

  TIMEOUT=300

# Break width '='

  BREAK=150

  # Set Nautobot Variables

	set_nautovariables
	NAUTO_MISSING_VARIABLES=()

#Missing Variables

	title="Looking for missing Nautobot Deployment Variables"
	print_title

	# Loop NAUTO_VARIABLES looking for missing variables

		COUNT=${#NAUTO_VARIABLES[@]}
		for ((i=0; i<$COUNT; i++)); do
			    NAME=${!NAUTO_VARIABLES[i]:0:1}
			    VALUE=${!NAUTO_VARIABLES[i]:1:1}
			    DESC=${!NAUTO_VARIABLES[i]:2:1}

			    if [[ -z "${VALUE}" ]]; then
			    	echo "Name: ${NAME}"
			    	printf "Value: ${RED}${NAME} is undefined\n${Color_Off}"
			        echo "Description: ${DESC}"
			        printf ${WHITE}"=%.0s"	$(seq 1 ${BREAK})${Color_Off}
			        printf "\n${Color_Off}"
			        NAUTO_MISSING_VARIABLES+=( "NAUTO_VARIABLE_$(expr $i + 1)[@]" )
			    fi
		done

	# Loop NAUTO_MISSING_VARIABLES to give user option to define any missing variables

		COUNT=${#NAUTO_MISSING_VARIABLES[@]}
		for ((i=0; i<$COUNT; i++)); do
			NAME=${!NAUTO_MISSING_VARIABLES[i]:0:1}
			VALUE=${!NAUTO_MISSING_VARIABLES[i]:1:1}
			DESC=${!NAUTO_MISSING_VARIABLES[i]:2:1}
            printf "${YELLOW}No value provided for '${NAME}'\n${COLOUR_OFF}"
		    printf "${DESC}\n"
		    read -p "$(printf "${CYAN}Provide a value for '${NAME}': ${GREEN}")" $NAME
		    printf ${WHITE}"=%.0s"	$(seq 1 ${BREAK})${Color_Off}
			printf "\n${COLOUR_OFF}"
		done

	printf "${GREEN}Done\n${Color_Off}"

# Update nauto Variables

	set_nautovariables
	clear

# Loop NAUTO_VARIABLES to display variables to be used for K3s deployment.

	title="Variables to be using in K3s Deployment"
	print_title

	COUNT=${#NAUTO_VARIABLES[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!NAUTO_VARIABLES[i]:0:1}
		VALUE=${!NAUTO_VARIABLES[i]:1:1}
		DESC=${!NAUTO_VARIABLES[i]:2:1}

		if [[ -z "${VALUE}" ]]; then
			echo "Name: ${NAME}"
			printf "Value: ${RED}${NAME} is undefined\n${Color_Off}"
			echo "Description: ${DESC}"
			printf ${WHITE}"=%.0s"	$(seq 1 ${BREAK})${Color_Off}
			printf "\n${Color_Off}"
		else
			printf "Name: ${CYAN}${NAME}\n${Color_Off}"
			printf "Value: ${GREEN}${VALUE}\n${Color_Off}"
			printf "Description: ${WHITE}${DESC}\n${Color_Off}"
			printf ${BLUE}"=%.0s"	$(seq 1 ${BREAK}) \n
			printf "\n${Color_Off}"
		fi
	done

	printf "${GREEN}Done\n${Color_Off}"

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

#Create 'nautobot.yaml' file

	title="Creating 'nautobot.yaml' file"
	print_title

	sed -i "s/NAUTO_SUBDOMAIN/$NAUTO_SUBDOMAIN/g" nautobot.yaml
	sed -i "s/DOMAIN/$DOMAIN/g" nautobot.yaml
    sed -i "s/NAUTO_SQL_PW/$NAUTO_SQL_PW/g" nautobot.yaml
	sed -i "s/NAUTO_REDIS_PW/$NAUTO_REDIS_PW/g" nautobot.yaml
	sed -i "s/CERT_ISSUER/$CERT_ISSUER/g" nautobot.yaml

	printf "${GREEN}Done\n${Color_Off}"

## Add the below after './nautobot.yaml' in the deployment command to customise
   # --set-file nautobot.config=./nautobot_config.py

#Deploy nautobot with helm

	#https://github.com/nautobot/helm-charts
	helm repo add nautobot https://nautobot.github.io/helm-charts/
	helm repo update
	helm install "$NAUTO_RELEASE_NAME" nautobot/nautobot -f ./nautobot.yaml --namespace "$NAUTO_NAMESPACE" --create-namespace

#Wait for Nautobot to be Ready

	title="Waiting for Nautobot to be Ready"
	print_title

	nautopods=$(kubectl get pods -n ${NAUTO_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a nautopods <<< "$nautopods"
	
	#wait for there to be 6 pods in the nautobot namespace
	while [ ${#nautopods[@]} -ne 6 ]
	do
		nautopods=$(kubectl get pods -n ${NAUTO_NAMESPACE} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a nautopods <<< "$nautopods"
	done
	
	#wait for those 6 pods to be in a ready state
	for i in "${nautopods[@]}"; do
		kubectl wait -n ${NAUTO_NAMESPACE} --for=condition=Ready pod/${i} --timeout=300s
	done

	printf "${GREEN}Done\n${Color_Off}"


#Wait for Certificate to be assigned

	title="Waiting for Nautobot Certificate to be Ready"
	print_title

	awxcert=$(kubectl get certificate -n ${NAUTO_NAMESPACE} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a nautocert <<< "$nautocert"
	for i in "${nautocert[@]}"; do
		kubectl wait -n ${NAUTO_NAMESPACE} --for=condition=Ready certificate/${i} --timeout=300s
	done

	printf "${GREEN}Done\n${Color_Off}"

#Deployment of Nautobot complete

	title="Nautobot Deployment Complete"
	print_title

	pass=$(kubectl get secret --namespace ${NAUTO_NAMESPACE} nautobot-env -o jsonpath="{.data.NAUTOBOT_SUPERUSER_PASSWORD}" | base64 --decode)
	
	printf "${GREEN}You can now access your Nautobot Dashboard at https://${NAUTO_SUBDOMAIN}.${DOMAIN}\n${Color_Off}"
	printf "${GREEN}Username: admin\n${Color_Off}"
	printf "${GREEN}Password: ${pass}\n${Color_Off}"
	
	pass=