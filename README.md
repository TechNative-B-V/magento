# Magento stack

This repository holds all the files required for the magento stack with custom images made by devOps trainees.

## Requirements

For testing and building the image locally we require docker.
For deploying the stack to a kubernetes cluster we require both kubectl and helm cli to be installed.

[Docker Desktop](https://www.docker.com/products/docker-desktop/)

[Kubectl](https://kubernetes.io/docs/tasks/tools/)

[Helm](https://helm.sh/docs/intro/install/)

## Running locally

To run the magento stack on the local machine we use docker to run the stack in containers.

To start magento open a command prompt and navigate to the repository.
From here run ``` docker-compose up ```.
This wil build the images and start all the required containers for the stack.

Once the console returns ``` ready to handle connections ```  from the fpm container you can connect to the stack on ``` localhost ```.

If for some reason you need to check the database you can connect to it on
``` localhost:8000 ```, the login credentials can be found in the .env file.


## Updating the helm files

If changes are made to the helm templates or the values.yaml file we need to update our helm package (.tgz).

To do so we require the helm cli to be installed.
First remove the existing .tgz file, once removed we navigate to the helm folder in a command prompt.
From here we run the following command: ``` helm package . ```. This command creates a new .tgz package for us.

To finish it off we run ``` helm repo index . ```, updating our index.yaml with a new digest and updated timestamps. 

## Deploying new images

The deployment of new version tagged images is automated via a github action which can be found <a href="https://github.com/TechNative-B-V/magento/blob/master/.github/workflows/ImagePublish.yml" target="_blank">here</a>.

The github action will build the images and push it to the container registry defined in the .env file.
Depending on what branch is pushed different image tags will be used (e.g dev or latest).


## Installing to kubernetes

For installing the stack on a kubernetes cluster we require a few things:

* kubectl cli
* helm cli
* kubeconfig of the kubernetes cluster

We will be using the ``` helm install ``` command to deploy the magento stack on the cluster. More information about the command can be found [here](https://helm.sh/docs/helm/helm_install/).

update the [values.yml](https://github.com/TechNative-B-V/magento/blob/master/helm/values.yaml) file to configure how you wish to deploy the stack. By default we have disabled the deployment of a marriadb container since we default to using a managed service for the database.
To enable this change enabled to true in the mariadb section in the values file.

First make sure to navigate to the helm folder in a command prompt.
To install the stack on the default namespace we run the following command:

``` helm install magento ./technative-magento-0.1.0.tgz -f ./values.yaml --kubeconfig {path to kubeconfig} ```

## upgrading the kubernetes deployment

If you want to apply changes made to the helm templates or change some helm values we can update an existing deployment with the ``` helm upgrade ``` command, more info abou this command can be found [here](https://helm.sh/docs/helm/helm_upgrade/).

If changes are made in the helm templates make sure you create a new package (.tgz file) for information on how to do this check the **Updating the helm files** section of this file.

To update the deployment we run the following command:

``` helm upgrade -f ./values.yaml magento ./technative-magento-0.1.0.tgz --reuse-values --kubeconfig {path to kubeconfig} ```

We use the ``` --reuse-values ``` flag to only update helm values that have been changed.

