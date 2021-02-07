#!/bin/bash

# Written by Luke Shannon to help get an image into Google's Cloud Container Registry
# This script is intended for those who are new to both Docker and GCP

###############################
# Execution Logic
###############################

# Check if script usage was requested
check_for_usage_argument

# This script should be ran as sudo
test_for_sudo

#This script requires gcloud
test_for_gcloud

#This script requires docker
test_for_docker

#Get gcloud pointing at the correct project
change_project_routine

#Verify the correct location before proceeding
verify_location_routine

#Get the image name
collect_image_name_routine

#Build the docker image
build_docker_image

#Deploy the docker image
deploy_docker_image

###############################
# Function Definitions
###############################

check_for_usage_argument () {
	if [ $# -eq 1 ]; then
		if [ $1 = "--usage" ]; then
		   echo "Usage: build-deploy-docker.sh";
	    	echo "Run this script in the root of a Spring Boot directory as sudo. Ensure there is a Dockerfile at the same level";
	    	echo "In a successful run this script will build a Docker image locally and deploy it to GCP's Cloud Container Registry"
	    	echo "This script is for learning purposes only and is not intended for Production"
	    	echo "Have a nice day";
	    	exit 0;
		fi
	fi
}

build_docker_image () {
	echo "Building the Docker Image..."
	sudo docker build -t gcr.io/woddrive-nonprod/wod-service:latest .
}

deploy_docker_image () {
	echo "Pushing to Cloud Run..."
	sudo docker push gcr.io/woddrive-nonprod/wod-service:latest
}


test_for_sudo () {
	if [ "$EUID" -ne 0 ]
  		then echo "Please run this script using sudo"
  		exit 1;
	fi
}

test_for_gcloud () {
	OUTPUT="$(gcloud --version)"
	if [[ $OUTPUT == *"Command 'gcloud' not found"* ]]; then
  		echo "You need GCloud to run this script"
  		echo "Please follow these directions: "
  		echo "https://cloud.google.com/sdk/docs/install"
  		exit 1;
	fi
}

test_for_docker () {
	OUTPUT="$(docker --version)"
	if [[ $OUTPUT == *"Command 'docker' not found"* ]]; then
  		echo "You need Docker to run this script: "
  		echo "Please follow these directions"
  		echo "https://docs.docker.com/get-docker/"
  		exit 1;
	fi
}

change_project_routine () {
	echo "Your current project is: `$(gcloud info | grep -oP 'Project: (\[.+\])')`"
	echo "Do you want to change your project? (Type 'Y' to change)"
	read CHANGEPROJECT
	if [ "$CHANGEPROJECT" = "Y" ]; then
	  echo "Type in your project name:";
	  read PROJECTNAME;
	  echo "Attempting to set project name too $PROJECTNAME..."
	  sudo gcloud config set project $PROJECTNAME;
	  echo "Running the Auth command. Open the link that is provided in your browser to authenticate..."
	  sudo gcloud auth login
	fi
}

verify_location_routine () {
	echo "Your current directory is $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo "Make sure this is the correct directory for `$(gcloud info | grep -oP 'Project: (\[.+\])')` otherwise you risk publishing an wrong DockerImage to a project"
	verify_to_proceed
}

verify_container_registry_enabled () {
	echo "Ensure the Container Registry API is enabled in your project"
	echo "https://cloud.google.com/container-registry"
  echo "Do you want this script to enable the API? (Type Y to proceed):"
  read PROCEED
  if [ "$PROCEED" != "Y" ]; then
    echo "Running 'gcloud services enable containerregistry.googleapis.com'"
    gcloud services enable containerregistry.googleapis.com
  fi
	verify_to_proceed
}

collect_image_name_routine () {
	echo "Here are the images currently in the project."
	gcloud container images list
	echo "What image do you wish to deploy too?"
	read IMAGENAME
}

first_time_docker () {
	echo "Is this your first time publishing a Docker Image to the project?"
	read First_Time_Docker
	if [ "$CONFIRMATION" = "Y" ]; then
      echo "Running 'auth configure-docker'"
      gcloud auth configure-docker
	fi
}

verify_to_proceed () {
	echo "Continue? (Type 'Y' to proceed)"
	read CONTINUE
	if [ "$CONTINUE" != "Y" ]; then
	  echo "Goodbye for now - Be safe out there"
	  exit 0;
	fi
}
