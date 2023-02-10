#!/bin/bash

# Define variables for Nautobot deployment on K3s (uncomment lines, and populate variables - not required if using other methods of variable population).


    #nautons='' #This is the namespace that Nautobot will be deployed to.
    #nautosubd='' #This is the subdomain that will be used to serve your Nautobot dashboard.
	#nautopsqlpw='' #this is the paasword that the Nautobot postgres user will have.
    #nautoredispw='' #this is the paasword that the Nautobot redis will have.
    #domain='' #This is the domain that your services will be available on e.g. 'yourdomain.com'.

#Create Functions

	set_nautovars () {

		# Define nautovar array containing required variables for K3s deployment
		nautovar_1=("nautons" "$nautons" "This is the namespace that nauto will be deployed to.")
		nautovar_2=("nautosubd" "$nautosubd" "This is the subdomain that will be used to serve your nauto Dashboard. e.g. 'nauto' will become nauto.yourdomain.com")
		nautovar_3=("nautopsqlpw" "$nautopsqlpw" "This is the paasword that the Nautobot postgres user will have.")
        nautovar_4=("nautoredispw" "$nautoredispw" "This is the paasword that the Nautobot redis will have.")
        nautovar_5=("domain" "$domain" "This is the domain that your services will be available on e.g. 'yourdomain.com'")

	 # Combine nautovar arrays int the nautovars array
	 nautovars=(
		 nautovar_1[@]
		 nautovar_2[@]
		 nautovar_3[@]
		 nautovar_4[@]
		 nautovar_5[@]
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

  # Set Nautobot Variables

	set_nautovars
	nautomissingvars=()

#Missing Variables

	title="Looking for missing Nautobot Deployment Variables"
	print_title

	# Loop nautovars looking for missing variables

		COUNT=${#nautovars[@]}
		for ((i=0; i<$COUNT; i++)); do
			NAME=${!nautovars[i]:0:1}
			VALUE=${!nautovars[i]:1:1}
			DESC=${!nautovars[i]:2:1}

			if [[ -z "${VALUE}" ]]; then
				echo "Name: ${NAME}"
				printf "Value: ${Red}${NAME} is undefined\n${Color_Off}"
			echo "Description: ${DESC}"
			printf ${White}"=%.0s"	$(seq 1 100)${Color_Off}
			printf "\n${Color_Off}"
			nautomissingvars+=( "nautovar_$(expr $i + 1)[@]" )
			fi
		done

	# Loop nautomissingvars to give user option to define any missing variables

		COUNT=${#nautomissingvars[@]}
		for ((i=0; i<$COUNT; i++)); do
			NAME=${!nautomissingvars[i]:0:1}
			VALUE=${!nautomissingvars[i]:1:1}
			DESC=${!nautomissingvars[i]:2:1}

			read -p "Would you like to provide a value for $NAME? " -r
			echo		# (optional) move to a new line
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				read -p "Enter value for $NAME: " $NAME
			fi
		done

	printf "${Green}Done\n${Color_Off}"

# Update nauto Variables

	set_nautovars
	clear

# Loop nautovars to display variables to be used for K3s deployment.

	title="Variables to be using in K3s Deployment"
	print_title

	COUNT=${#nautovars[@]}
	for ((i=0; i<$COUNT; i++)); do
		NAME=${!nautovars[i]:0:1}
		VALUE=${!nautovars[i]:1:1}
		DESC=${!nautovars[i]:2:1}

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

#Create 'nautobot.yml' file

	title="Creating 'nautobot.yml' file"
	print_title

	sed -i "s/nautosubd/$nautosubd/g" nautobot.yml
	sed -i "s/domain/$domain/g" nautobot.yml
    sed -i "s/nautosqlpw/$nautosqlpw/g" nautobot.yml
	sed -i "s/nautoredispq/$nautoredispw/g" nautobot.yml

	printf "${Green}Done\n${Color_Off}"

#Deploy nautobot with helm

  #https://github.com/nautobot/helm-charts
  helm repo add nautobot https://nautobot.github.io/helm-charts/
  helm repo update
  helm install "$ingname" nautobot/nautobot -f ./nautobot.yml --set-file nautobot.config=./nautobot_config.py --namespace "$ingns" --create-namespace

#Wait for Nautobot to be Ready

	title="Waiting for Nautobot to be Ready"
	print_title

	nautopods=$(kubectl get pods -n ${nautons} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a nautopods <<< "$nautopods"
	
	#wait for there to be 6 pods in the nautobot namespace
	while [ ${#nautopods[@]} -ne 6 ]
	do
		nautopods=$(kubectl get pods -n ${nautons} -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a nautopods <<< "$nautopods"
	done
	
	#wait for those 6 pods to be in a ready state
	for i in "${nautopods[@]}"; do
		kubectl wait -n ${nautons} --for=condition=Ready pod/${i}
	done

	printf "${Green}Done\n${Color_Off}"


#Wait for Certificate to be assigned

	title="Waiting for Nautobot Certificate to be Ready"
	print_title

	awxcert=$(kubectl get certificate -n ${nautons} -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a nautocert <<< "$nautocert"
	for i in "${nautocert[@]}"; do
		kubectl wait -n ${nautons} --for=condition=Ready certificate/${i}
	done

	printf "${Green}Done\n${Color_Off}"

#Deployment of Nautobot complete

	title="Nautobot Deployment Complete"
	print_title

	pass=$(kubectl get secret --namespace nautobot nautobot-env -o jsonpath="{.data.NAUTOBOT_SUPERUSER_PASSWORD}" | base64 --decode)
	
	printf "${Green}You can now access your Nautobot Dashboard at https://${nautosubd}.${domain}\n${Color_Off}"
	printf "${Green}Username: admin\n${Color_Off}"
	printf "${Green}Password: ${pass}\n${Color_Off}"
	
	pass=