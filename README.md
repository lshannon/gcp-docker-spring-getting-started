# Getting Your Spring Boot Image Into Google Cloud

This repository is intended for Spring Boot developers who are new to both Docker and GCP. If you have expertise on either, this is probably not for you.

## Disclaimer

This is not intended for Production. Ensure you review the script before running it. The author is not responsible for any unintended consequences of this script. You have been warned.

## Requirements

This script is intended for the following environment:

- Spring Boot application built with Maven
- GCP Account (https://cloud.google.com/)
- glcoud installed locally (https://cloud.google.com/sdk/docs/install)
- docker installed locally (https://docs.docker.com/get-docker/)

This script was built to run in a Ubuntu environment. There is no guarantee it will work in any other environment

## Usage

Run the script with the argument './build-deploy-docker-gcp.sh --usage' to get instructions on what the script does

## Installation

Download the script and Dockerfile from this repo into the root direction of your Spring Boot Maven Application

To get the script in while the root of the project:

```shell

wget https://raw.githubusercontent.com/lshannon/gcp-docker-spring-getting-started/main/build-deploy-docker-gcp.sh

```

To get the Docker image in the root of the project:

```shell

https://raw.githubusercontent.com/lshannon/gcp-docker-spring-getting-started/main/Dockerfile

```

## Execution

Run the script as sudo and follow the prompts
