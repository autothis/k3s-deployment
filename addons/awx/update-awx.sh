#!/bin/bash

#Create Functions

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

# Get AWX Namespace

	TITLE="Getting latest AWX Version Number"
	print_title

	# Get AWX namespace from the 'kustomization.yaml' file
	AWX_NAMESPACE=$(awk '/namespace: /{print $NF}' kustomization.yaml)

	printf "The AWX Namespace: ${CYAN}${AWX_NAMESPACE}\n${COLOUR_OFF}"

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Get AWX URL

	TITLE="Getting latest AWX Version Number"
	print_title

	# Get AWX namespace from the 'awx.yaml' file
	AWX_URL=$(awk '/hostname: /{print $NF}' awx.yaml)

	printf "The AWX Namespace: ${CYAN}${AWX_NAMESPACE}\n${COLOUR_OFF}"

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Get latest AWX Version

	TITLE="Getting latest AWX Version Number"
	print_title

	# Query AWX Github page for latest AWX version number
	URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ansible/awx-operator/releases/latest)
	IFS='/ ' read -r -a awxlatest <<< "$URL"
	AWX_VERSION=${awxlatest[-1]}

	printf "Latest AWX version is: ${CYAN}${AWX_VERSION}\n${COLOUR_OFF}"

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Update Version Number in 'kustomization.yaml' file

	TITLE="Updating Version Number in 'kustomization.yaml' file"
	print_title
	
	# Update 'kustomization.yaml' file with the latest AWX version number
	sed -i -E "/ref/s/ref=.*/ref=${AWX_VERSION}/" kustomization.yaml
	sed -i -E "/newTag/s/newTag: .*/newTag: ${AWX_VERSION}/" kustomization.yaml

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Remove Operator

	TITLE="Removing Operator"
	print_title

	# Get Namespace from 'kustomization.yaml' file
	AWX_NAMESPACE=`sed -n 's/^namespace: \(.*\)/\1/p' < kustomization.yaml`

	# Delete AWX Operator Pods
	kubectl -n ${AWX_NAMESPACE} delete deployment awx-operator-controller-manager
	kubectl -n ${AWX_NAMESPACE} delete serviceaccount awx-operator-controller-manager
	kubectl -n ${AWX_NAMESPACE} delete rolebinding awx-operator-awx-manager-rolebinding
	kubectl -n ${AWX_NAMESPACE} delete role awx-operator-awx-manager-role

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Deploy AWX Operator

	TITLE="Creating AWX Operator"
	print_title

	# Build Kustomize file, and apply to Kubernetes to create replacement Operator Pods
	kustomize build . | kubectl apply -f -

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Wait for AWX Operator to be Ready

	TITLE="Waiting for AWX Operator to be Ready"
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
		kubectl wait -n ${AWX_NAMESPACE} --for=condition=Ready pod/${i} --timeout=${TIMEOUT}
	done

	printf "${GREEN}Done\n${COLOUR_OFF}"

# Deployment of AWX complete

	TITLE="ASX Deployment Complete"
	print_title

	# Get AWX password from secrets
	AWX_PASSWORD=$(kubectl get secret awx-admin-password -n ${AWX_NAMESPACE} -o jsonpath="{.data.password}" | base64 --decode)
	
	# Print AWX Details to screen for user
	printf "${GREEN}You can now access your AWX Dashboard at https://${AWX_URL}\n${COLOUR_OFF}"
	printf "${GREEN}Username: super\n${COLOUR_OFF}"
	printf "${GREEN}Password: ${AWX_PASSWORD}\n${COLOUR_OFF}"
	
	# Empty Password Variable
	AWX_PASSWORD=