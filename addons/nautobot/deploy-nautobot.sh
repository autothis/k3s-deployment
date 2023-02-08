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

	 # Combine awxvar arrays int the awxvars array
	 awxvars=(
		 awxvar_1[@]
		 awxvar_2[@]
		 awxvar_3[@]
		 awxvar_4[@]
		 awxvar_5[@]
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

# Get current working directory

  k3sdeploypath=$(pwd)


  #https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
  helm repo add nginx-stable https://helm.nginx.com/stable
  helm repo update
  helm install "$ingname" nginx-stable/nginx-ingress --namespace "$ingns" --create-namespace