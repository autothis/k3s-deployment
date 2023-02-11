#!/bin/bash

# Define variables for AWX deployment on K3s (uncomment lines, and populate variables - not required if using other methods of variable population).

	#awxns='' #This is the namespace that AWX will be deployed to.
	#awxvers='' #This is the version of AWX to be deployed, this variable will automatically populated.
	#awxsubd='' #This is the subdomain that will be used to serve your AWX dashboard.
	#domain='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.

#Create Functions

	set_awxvars () {

		# Define awxvar array containing required variables for K3s deployment
		awxvar_1=("awxns" "$awxns" "This is the namespace that AWX will be deployed to.")
		awxvar_2=("awxverso" "$awxvers" "This is the version of AWX to be deployed, this variable will automatically populated.")
		awxvar_3=("awxsubd" "$awxsubd" "This is the subdomain that will be used to serve your AWX Dashboard. e.g. 'awx' will become awx.yourdomain.com")
		awxvar_4=("domain" "$domain" "This is the domain that your services will be available on e.g. 'yourdomain.com'")

	 # Combine awxvar arrays int the awxvars array
	 awxvars=(
		 awxvar_1[@]
		 awxvar_2[@]
		 awxvar_3[@]
		 awxvar_4[@]
	 )
	}

	print_title () {

		printf ${Yellow}"#%.0s"	$(seq 1 ${break})
		printf "\n"
		printf "$title \n"
		printf "#%.0s"	$(seq 1 ${break})
		printf "\n"${Color_Off}

	}

#Define Output Colours

	# Reset
	Color_Off='\033[0m'			 # Text Reset

	# Regular Colors
	Black='\033[0;30m'				# Black
	Red='\033[0;31m'					# Red
	Green='\033[0;32m'				# Green
	Yellow='\033[0;33m'			 # Yellow
	Blue='\033[0;34m'				 # Blue
	Purple='\033[0;35m'			 # Purple
	Cyan='\033[0;36m'				 # Cyan
	White='\033[0;37m'				# White

# Get current working directory

  k3sdeploypath=$(pwd)

# Timeout in seconds

  timeout=300

# Break width '='

  break=150

# Get latest AWX Version

	title="Getting latest AWX Version Number"
	print_title

	# Query AWX Github page for latest AWX version number
	url=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ansible/awx-operator/releases/latest)
	IFS='/ ' read -r -a awxlatest <<< "$url"
	awxvers=${awxlatest[-1]}

	printf "Latest AWX version is: ${Cyan}${awxvers}\n${Color_Off}"

	printf "${Green}Done\n${Color_Off}"

# Set AWX Variables

	set_awxvars
	awxmissingvars=()

# Missing Variables

	title="Looking for missing AWX Deployment Variables"
	print_title

	# Loop awxvars looking for missing variables
	COUNT=${#awxvars[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!awxvars[i]:0:1}
		VALUE=${!awxvars[i]:1:1}
		DESC=${!awxvars[i]:2:1}
		if [[ -z "${VALUE}" ]]; then
			echo "Name: ${NAME}"
			printf "Value: ${Red}${NAME} is undefined\n${Color_Off}"
			echo "Description: ${DESC}"
			printf ${White}"=%.0s"	$(seq 1 ${break})${Color_Off}
			printf "\n${Color_Off}"
			awxmissingvars+=( "awxvar_$(expr $i + 1)[@]" )
		fi
	done

	# Loop awxmissingvars to give user option to define any missing variables
	COUNT=${#awxmissingvars[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!awxmissingvars[i]:0:1}
		VALUE=${!awxmissingvars[i]:1:1}
		DESC=${!awxmissingvars[i]:2:1}
		printf "${Yellow}No value provided for '${NAME}'\n${Color_Off}"
           printf "$DESC\n"
           read -p "$(printf "${Cyan}Provide a value for '${NAME}': ${Green}")" $NAME
           printf "${Color_Off}"
	done

	printf "${Green}Done\n${Color_Off}"

# Update AWX Variables

	set_awxvars
	clear

# Loop awxvars to display variables to be used for K3s deployment.

	title="Variables to be using in K3s Deployment"
	print_title

	COUNT=${#awxvars[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!awxvars[i]:0:1}
		VALUE=${!awxvars[i]:1:1}
		DESC=${!awxvars[i]:2:1}

		if [[ -z "${VALUE}" ]]; then
			echo "Name: ${NAME}"
			printf "Value: ${Red}${NAME} is undefined\n${Color_Off}"
			echo "Description: ${DESC}"
			printf ${White}"=%.0s"	$(seq 1 ${break})${Color_Off}
			printf "\n${Color_Off}"
		else
			printf "Name: ${Cyan}${NAME}\n${Color_Off}"
			printf "Value: ${Green}${VALUE}\n${Color_Off}"
			printf "Description: ${White}${DESC}\n${Color_Off}"
			printf ${Blue}"=%.0s"	$(seq 1 ${break}) \n
			printf "\n${Color_Off}"
		fi
	done

	printf "${Green}Done\n${Color_Off}"

# Confirm Variables before Deployment

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

# Update Version Number in 'kustomization.yaml' file

	title="Updating Version Number in 'kustomization.yaml' file"
	print_title
	
	# Update 'kustomization.yaml' file with the latest AWX version number
	sed -i -E "/ref/s/ref=.*/ref=${awxvers}/" kustomization.yaml
	sed -i -E "/newTag/s/newTag: .*/newTag: ${awxvers}/" kustomization.yaml
	sed -i "s/awxns/$awxns/g" kustomization.yaml

	printf "${Green}Done\n${Color_Off}"

# Create 'awx.yaml' file.

	title="Creating 'awx.yaml' file"
	print_title

	# Update Variables in 'awx.yaml' file
	sed -i "s/domain/$domain/g" awx.yaml
	sed -i "s/awxns/$awxns/g" awx.yaml
	sed -i "s/awxsubd/$awxsubd/g" awx.yaml

	printf "${Green}Done\n${Color_Off}"

# Deploy AWX Operator

	title="Deploying AWX Operator"
	print_title

	# Build Kustomize file, and apply to Kubernetes to create replacement Operator Pods
	kustomize build . | kubectl apply -f -

	printf "${Green}Done\n${Color_Off}"

# Wait for AWX Operator to be Ready

	title="Waiting for AWX Operator to be Ready"
	print_title

	# Get Pods in AWX namespace
	awxpods=$(kubectl get pods -n ${awxns} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a awxpods <<< "$awxpods"

	# Wait for those pods to be in a ready state
	for i in "${awxpods[@]}"; do
		kubectl wait -n ${awxns} --for=condition=Ready pod/${i} --timeout=300s
	done

	printf "${Green}Done\n${Color_Off}"

# Deploy AWX Operator

	title="Creating AWX Operator"
	print_title

	# Uncomment 'awx.yaml' resource in 'kustomization.yaml' file
	sed -i "s/#-/-/g" kustomization.yaml

	# Build Kustomize file, and apply to Kubernetes to create replacement Operator Pods
	kustomize build . | kubectl apply -f -

	printf "${Green}Done\n${Color_Off}"

# Wait for AWX to be Ready

	title="Waiting for AWX to be Ready"
	print_title

	# Get Pods in the AWX Namespace
	awxpods=$(kubectl get pods -n ${awxns} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a awxpods <<< "$awxpods"

	# Wait for there to be 3 pods in the AWX namespace
	while [ ${#awxpods[@]} -ne 3 ]
	do
		awxpods=$(kubectl get pods -n ${awxns} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a awxpods <<< "$awxpods"
	done
	
	# Wait for those 3 pods to be in a ready state
	for i in "${awxpods[@]}"; do
		kubectl wait -n ${awxns} --for=condition=Ready pod/${i} --timeout=300s
	done

	printf "${Green}Done\n${Color_Off}"

#Wait for Certificate to be assigned

	title="Waiting for AWX Certificate to be Ready"
	print_title

	# Query Certificates status in the AWX Namespace
	awxcert=$(kubectl get certificate -n ${awxns} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a awxcert <<< "$awxcert"
	for i in "${awxcert[@]}"; do
		kubectl wait -n ${awxns} --for=condition=Ready certificate/${i} --timeout=300s
	done

	printf "${Green}Done\n${Color_Off}"

# Deployment of AWX complete

	title="ASX Deployment Complete"
	print_title

	# Get AWX password from secrets
	pass=$(kubectl get secret awx-admin-password -n ${awxns} -o jsonpath="{.data.password}" | base64 --decode)
	
	# Print AWX Details to screen for user
	printf "${Green}You can now access your AWX Dashboard at https://${awxsubd}.${domain}\n${Color_Off}"
	printf "${Green}Username: super\n${Color_Off}"
	printf "${Green}Password: ${pass}\n${Color_Off}"
	
	# Empty Password Variable
	pass=
