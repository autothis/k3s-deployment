#!/bin/bash

#Create Functions

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

#Update Version Number in 'kustomization.yaml' file

	title="Updating Version Number in 'kustomization.yaml' file"
	print_title
	
	sed -i -E "/ref/s/ref=.*/ref=${awxvers}/" kustomization.yaml
	sed -i -E "/newTag/s/newTag: .*/newTag: ${awxvers}/" kustomization.yaml

	printf "${Green}Done\n${Color_Off}"

#Remove Operator

	title="Removing Operator"
	print_title

	awxns=`sed -n 's/^namespace: \(.*\)/\1/p' < kustomization.yaml`

	kubectl -n ${awxns} delete deployment awx-operator-controller-manager
	kubectl -n ${awxns} delete serviceaccount awx-operator-controller-manager
	kubectl -n ${awxns} delete rolebinding awx-operator-awx-manager-rolebinding
	kubectl -n ${awxns} delete role awx-operator-awx-manager-role

	printf "${Green}Done\n${Color_Off}"

#Deploy AWX Operator

	title="Creating AWX Operator"
	print_title

	kustomize build . | kubectl apply -f -

	printf "${Green}Done\n${Color_Off}"

#Wait for AWX Operator to be Ready

	title="Waiting for AWX Operator to be Ready"
	print_title

	awxpods=$(kubectl get pods -n awx -o 'jsonpath={..metadata.name}')
	IFS='/ ' read -r -a awxpods <<< "$awxpods"

	#wait for there to be 3 pods in the AWX namespace
	while [ ${#awxpods[@]} -ne 3 ]
	do
		awxpods=$(kubectl get pods -n awx -o 'jsonpath={..metadata.name}')
		IFS='/ ' read -r -a awxpods <<< "$awxpods"
	done
	
	#wait for those 3 pods to be in a ready state
	for i in "${awxpods[@]}"; do
		kubectl wait -n awx --for=condition=Ready pod/${i} --timeout=300s
	done

	printf "${Green}Done\n${Color_Off}"

#Deployment of AWX complete

	title="ASX Deployment Complete"
	print_title

	pass=$(kubectl get secret awx-admin-password -o jsonpath="{.data.password}" | base64 --decode)
	
	printf "${Green}You can now access your AWX Dashboard at https://${awxsubd}.${domain}\n${Color_Off}"
	printf "${Green}Username: super\n${Color_Off}"
	printf "${Green}Password: ${pass}\n${Color_Off}"
	
	pass=
