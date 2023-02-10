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

		printf ${Yellow}"#%.0s"	$(seq 1 100)
		printf "\n"
		printf "$title \n"
		printf "#%.0s"	$(seq 1 100)
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

#Get latest AWX Version

	title="Getting latest AWX Version Number"
	print_title

	url=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ansible/awx-operator/releases/latest)
	IFS='/ ' read -r -a awxlatest <<< "$url"
	awxvers=${awxlatest[-1]}

	printf "${Green}Done\n${Color_Off}"

# Set AWX Variables

	set_awxvars
	awxmissingvars=()

#Missing Variables

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
			printf ${White}"=%.0s"	$(seq 1 100)${Color_Off}
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

			read -p "Would you like to provide a value for $NAME? " -r
			echo		# (optional) move to a new line
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				read -p "Enter value for $NAME: " $NAME
			fi
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
			printf ${White}"=%.0s"	$(seq 1 100)${Color_Off}
			printf "\n${Color_Off}"
		else
			printf "Name: ${Cyan}${NAME}\n${Color_Off}"
			printf "Value: ${Green}${VALUE}\n${Color_Off}"
			printf "Description: ${White}${DESC}\n${Color_Off}"
			printf ${Blue}"=%.0s"	$(seq 1 100) \n
			printf "\n${Color_Off}"
		fi
	done

	printf "${Green}Done\n${Color_Off}"

#Create 'kustomization.yaml' file.

	title="Creating 'kustomization.yaml' file"
	print_title

	sed -i "s/awxvers/$awxvers/g" kustomization.yaml
	sed -i "s/awxns/$awxns/g" kustomization.yaml

	printf "${Green}Done\n${Color_Off}"

#Create 'awx.yaml' file.

	title="Creating 'awx.yaml' file"
	print_title

	sed -i "s/domain/$domain/g" awx.yaml
	sed -i "s/awxns/$awxns/g" awx.yaml
	sed -i "s/awxsubd/$awxsubd/g" awx.yaml

	printf "${Green}Done\n${Color_Off}"

#Deploy AWX Operator

	title="Deploying AWX Operator"
	print_title

	kustomize build . | kubectl apply -f -

	printf "${Green}Done\n${Color_Off}"

#Wait for AWX Operator to be Ready

	title="Waiting for AWX Operator to be Ready"
	print_title

	awxpods=$(kubectl get pods -n ${awxns} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a awxpods <<< "$awxpods"
	for i in "${awxpods[@]}"; do
		kubectl wait --for=condition=Ready pod/${i}
	done

	printf "${Green}Done\n${Color_Off}"

#Deploy AWX

	title="Deploying AWX"
	print_title

	sed -i "s/#-/-/g" kustomization.yaml

	kustomize build . | kubectl apply -f -

	printf "${Green}Done\n${Color_Off}"

#Wait for AWX to be Ready

	title="Waiting for AWX to be Ready"
	print_title

	awxpods=$(kubectl get pods -n ${awxns} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a awxpods <<< "$awxpods"

	#wait for there to be 3 pods in the AWX namespace
	while [ ${#awxpods[@]} -ne 3 ]
	do
		awxpods=$(kubectl get pods -n ${awxns} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a awxpods <<< "$awxpods"
	done
	
	#wait for those 3 pods to be in a ready state
	for i in "${awxpods[@]}"; do
		kubectl wait --for=condition=Ready pod/${i}
	done

	printf "${Green}Done\n${Color_Off}"

#Wait for Certificate to be assigned

	title="Waiting for AWX Certificate to be Ready"
	print_title

	awxcert=$(kubectl get certificate -n ${awxns} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a awxcert <<< "$awxcert"
	for i in "${awxcert[@]}"; do
		kubectl wait --for=condition=Ready certificate/${i}
	done

	printf "${Green}Done\n${Color_Off}"

#Deployment of AWX complete

	title="ASX Deployment Complete"
	print_title

	pass=$(kubectl get secret awx-admin-password -n ${awxns} -o jsonpath="{.data.password}" | base64 --decode)
	
	printf "${Green}You can now access your AWX Dashboard at https://${awxsubd}.${domain}\n${Color_Off}"
	printf "${Green}Username: super\n${Color_Off}"
	printf "${Green}Password: ${pass}\n${Color_Off}"
	
	pass=
