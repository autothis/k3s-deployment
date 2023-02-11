#!/bin/bash

#Create Functions

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

# Get AWX Namespace

	title="Getting latest AWX Version Number"
	print_title

	# Get AWX namespace from the 'kustomization.yaml' file
	awxns=$(awk '/namespace: /{print $NF}' kustomization.yaml)

	printf "The AWX Namespace: ${Cyan}${awxns}\n${Color_Off}"

	printf "${Green}Done\n${Color_Off}"

# Get AWX URL

	title="Getting latest AWX Version Number"
	print_title

	# Get AWX namespace from the 'awx.yaml' file
	awxurl=$(awk '/hostname: /{print $NF}' awx.yaml)

	printf "The AWX Namespace: ${Cyan}${awxns}\n${Color_Off}"

	printf "${Green}Done\n${Color_Off}"

# Get latest AWX Version

	title="Getting latest AWX Version Number"
	print_title

	# Query AWX Github page for latest AWX version number
	url=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ansible/awx-operator/releases/latest)
	IFS='/ ' read -r -a awxlatest <<< "$url"
	awxvers=${awxlatest[-1]}

	printf "Latest AWX version is: ${Cyan}${awxvers}\n${Color_Off}"

	printf "${Green}Done\n${Color_Off}"

# Update Version Number in 'kustomization.yaml' file

	title="Updating Version Number in 'kustomization.yaml' file"
	print_title
	
	# Update 'kustomization.yaml' file with the latest AWX version number
	sed -i -E "/ref/s/ref=.*/ref=${awxvers}/" kustomization.yaml
	sed -i -E "/newTag/s/newTag: .*/newTag: ${awxvers}/" kustomization.yaml

	printf "${Green}Done\n${Color_Off}"

# Remove Operator

	title="Removing Operator"
	print_title

	# Get Namespace from 'kustomization.yaml' file
	awxns=`sed -n 's/^namespace: \(.*\)/\1/p' < kustomization.yaml`

	# Delete AWX Operator Pods
	kubectl -n ${awxns} delete deployment awx-operator-controller-manager
	kubectl -n ${awxns} delete serviceaccount awx-operator-controller-manager
	kubectl -n ${awxns} delete rolebinding awx-operator-awx-manager-rolebinding
	kubectl -n ${awxns} delete role awx-operator-awx-manager-role

	printf "${Green}Done\n${Color_Off}"

# Deploy AWX Operator

	title="Creating AWX Operator"
	print_title

	# Build Kustomize file, and apply to Kubernetes to create replacement Operator Pods
	kustomize build . | kubectl apply -f -

	printf "${Green}Done\n${Color_Off}"

# Wait for AWX Operator to be Ready

	title="Waiting for AWX Operator to be Ready"
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

# Deployment of AWX complete

	title="ASX Deployment Complete"
	print_title

	# Get AWX password from secrets
	pass=$(kubectl get secret awx-admin-password -n ${awxns} -o jsonpath="{.data.password}" | base64 --decode)
	
	# Print AWX Details to screen for user
	printf "${Green}You can now access your AWX Dashboard at https://${awxurl}\n${Color_Off}"
	printf "${Green}Username: super\n${Color_Off}"
	printf "${Green}Password: ${pass}\n${Color_Off}"
	
	# Empty Password Variable
	pass=