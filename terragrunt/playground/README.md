# GovStack Sandbox Infrastructure

This repository is a part of the [GovStack Sandbox](https://govstack.gitbook.io/sandbox).

The GovStack Sandbox aims to be an isolated, safe environment simulating a small governmental e-service system (a reference implementation of the GovStack). It is a demonstration environment for learning and a technical environment for testing and developing digital government services based on the GovStack approach.

The Sandbox Infrastructure provides the lowest layer of the Sandbox — a Kubernetes environment for deploying and running compatible [building block](https://govstack.gitbook.io/specification/) implementations.

## Prerequisites

For OCI cloud provider

-   Generate admin user api keys as per [OCI Docs](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two)
-   Capture the values for
    - user_id
    - tenancy_id
    - fingerprint
    - region
    - private_key
-   Create a customer secret key for storing terraform state in remote bucket as per [OCI Docs](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm#usingAPI)
-   Capture the values for
    - s3 access key
    - s3 secret key
    - s3 region
    - s3 comptability api endpoint
-   Create bucket for storing terraform state files
    - capture the name of the bucket

## Create docker image
```
    git clone https://github.com/oci-sunbird/govstack-sandbox-infra-oci.git
    cd control-center
    docker build -t control-center-iac-devops .

```

## Start the container

```
docker run -d --name <container_name> control-center-iac-devops sh -c 'while true; do echo "Running"; sleep 360000; done'

```

## Login to the container & set the env variables

```
docker exec -it <container_name> /bin/bash

cd /iac-run-dir
modify environment variables in setenv as appropriate

source setenv
./init.sh
cd /iac-run-dir/govstack-sandbox-infra-oci/terragrunt/playground
modify environment.yaml file as appropriate

e.g

region: "ap-osaka-1"
tenancy_id: "ocid1.tenancy.oc1..aaaaaaaa"
compartment_id: "ocid1.compartment.oc1..aaaaaaaa"
ad_count: 1
cluster_name: "govstackplayground"
ansible_collection_tag: "main"
ansible_collection_url: "git+https://github.com/oci-sunbird/govstack-sandbox-infra-oci.git#/ansible/govstack/iac"
tags:
  {
    "Origin": "Terraform",
    "workload_name": "govstack-sandbox-playground",
    "workload_env": "playground",
    "workload_owner": "Owner-Name",
  }

```

## Build infrastructure

This IaC uses opentofu and terragrunt for managing the project hierarchy. Entire provsioning roughly takes about 30 min.

```
docker exec -it <container_name> /bin/bash
cd /iac-run-dir
source setenv
cd /iac-run-dir/govstack-sandbox-infra-oci/terragrunt/playground
./run.sh

```

## Post Provisioning

The iac script will output the relevant information for setting up cicd variables in circleci e.g

```
OCI Authentication Details For CI/CD
------------------------------------
OCI_CLI_USER=ocid1.user.oc1..aaaaaaaaddmawo
OCI_CLI_FINGERPRINT=ff:4d:
OCI_CLI_TENANCY=ocid1.tenancy.oc1..aaaaaaaa
OCI_CLI_REGION=ap-osaka-1
OCI_CLI_KEY_CONTENT_B64=LS0tLS1CRUdJTiBSU0Eg=


CI/CD Environment variables
---------------------------
CONTAINER_REGISTRY=kix.ocir.io/xyz
DOCKER_SERVER=kix.ocir.io
DOCKER_USERNAME=xyz/govstackplayground-bastion-ci
DOCKER_PASSWORD=********
OKE_CLUSTER_ID=ocid1.cluster.oc1.ap-osaka-1.aaaaaaaa

```

It will also give the bastion or operator vm details to manage the oke cluster

```
Bastion Details:
----------------
bastion user: ubuntu
bastion public ip: a.b.c.d
bastion private key:
<ssh private key>

login to the bastion node

sudo su -
kubectl -n usct get pods

```

The provisioning deploys the sample USCT usecase as per [DIY](https://github.com/oci-sunbird/sandbox-usecase-usct-backend/blob/main/docs/diy.md)


## Cleanup infrastructure

```
docker exec -it <container_name> /bin/bash
cd /iac-run-dir
source setenv
cd /iac-run-dir/govstack-sandbox-infra-oci/terragrunt/playground
./deleteAll.sh

```