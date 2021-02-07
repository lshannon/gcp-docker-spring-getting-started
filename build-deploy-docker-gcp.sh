#!/bin/bash

# Written by Luke Shannon to help get an image into Google's Cloud Container Registry
# This script is intended for those who are new to both Docker and GCP

###############################
# Global Variables
###############################
PROJECTNAME=""
IMAGENAME=""


###############################
# Function Definitions
###############################

function disclaimer {
   echo "------------------------------------------------------------------------";
   echo "Run this script in the root of a Spring Boot directory as sudo. Ensure there is a Dockerfile at the same level";
   echo "In a successful run this script will build a Docker image locally and deploy it to GCP's Cloud Container Registry"
   echo "This script is for learning purposes only and is not intended for Production"
   echo "------------------------------------------------------------------------";
}

function change_project_routine {
	PROJECTNAME=`gcloud info | grep -oP "Project: \[(\K.+)(?=\])"`
	echo "Your current project is: $PROJECTNAME"
	echo "Is $PROJECTNAME name correct? (Type 'N' to change the name, hit ENTER to continue):"
	read CORRECTPROJECTCONFIRMED
	if [ "$CORRECTPROJECTCONFIRMED" = "N" ]; then
		echo "OK, we can changed the project name"
		echo "To assist, here are your current projects"
		gcloud projects list
	  echo "Type the project name you want to deploy the image too:";
	  read NEWPROJECTNAME;
	  echo "Got it $NEWPROJECTNAME"
	  PROJECTNAME=$NEWPROJECTNAME
	fi
	echo "We will be proceeding with $PROJECTNAME as your project"
	gcloud config set project $PROJECTNAME;
	echo "Do you want to run 'gcloud auth login'? If you have not done this already, this script will fail. Type Y to run it, Hit Enter to continue without running it:"
  	read RUNAUTH
  	if [ "$RUNAUTH" == "Y" ]; then
    	echo "Running the Auth command. Open the link that is provided in your browser to authenticate..."
		gcloud auth login
  	fi
}

function build_docker_image {
	echo "Building the Docker Image..."
	docker build -t gcr.io/$PROJECTNAME/$IMAGENAME:latest .
}

function deploy_docker_image {
	echo "Pushing to Image to Container Registry..."
	docker push gcr.io/$PROJECTNAME/$IMAGENAME:latest
}


function test_for_sudo {
	if [ "$EUID" -ne 0 ]
  		then echo "Please run this script using sudo"
  		exit 1;
	fi
}

function test_for_gcloud {
	OUTPUT="$(gcloud --version)"
	if [[ $OUTPUT == *"Command 'gcloud' not found"* ]]; then
  		echo "You need GCloud to run this script"
  		echo "Please follow these directions: "
  		echo "https://cloud.google.com/sdk/docs/install"
  		exit 1;
	fi
}

function test_for_docker {
	OUTPUT="$(docker --version)"
	if [[ $OUTPUT == *"Command 'docker' not found"* ]]; then
  		echo "You need Docker to run this script: "
  		echo "Please follow these directions"
  		echo "https://docs.docker.com/get-docker/"
  		exit 1;
	fi
}

function verify_location_routine {
	echo "Your current directory is $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo "Make sure this is the correct directory for $PROJECTNAME otherwise you risk publishing an wrong DockerImage to a project"
	verify_to_proceed
}

function verify_container_registry_enabled {
	echo "Ensure the Container Registry API is enabled in your project"
	echo "https://cloud.google.com/container-registry"
  	echo "Do you want this script to enable the API? Type Y to run it, Type ENTER to continue without running it:"
  	read PROCEED
  	if [ "$PROCEED" == "Y" ]; then
    	echo "Running 'gcloud services enable containerregistry.googleapis.com'"
    	gcloud services enable containerregistry.googleapis.com
  	fi
}

function collect_image_name_routine {
	echo "Here are the images currently in the project."
	gcloud container images list
	echo "What image do you wish to deploy too? Hint: The images name will be the last part of the listing: gcr.io/<project name>/<image name>"
	read IMAGENAME
	echo "We will be proceeding with Image: $IMAGENAME in Project: $PROJECTNAME"
	verify_to_proceed
}

function first_time_docker {
	echo "Is this your first time publishing Docker Image $IMAGENAME to the project $PROJECTNAME? Type Y to configure $PROJECTNAME for Docker use. Type ENTER to continue"
	read FIRSTTIMEDOCKER
	if [ "$FIRSTTIMEDOCKER" == "Y" ]; then
      echo "Running 'auth configure-docker'"
      gcloud auth configure-docker
	fi
}

function verify_to_proceed {
	echo "Continue? (Type 'Y' to proceed)"
	read CONTINUE
	if [ "$CONTINUE" != "Y" ]; then
	  echo "Goodbye for now - Be safe out there"
	  exit 0;
	fi
}

###############################
# Execution Logic
###############################

# Check if script usage was requested
disclaimer

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

#Check if the Container Registry API is enabled
verify_container_registry_enabled

#Potential Docker Set Up
first_time_docker

#Build the docker image
build_docker_image

#Deploy the docker image
deploy_docker_image
