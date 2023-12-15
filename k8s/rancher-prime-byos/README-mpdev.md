# Interim instructions for working with mpdev testing

Basic steps to get things working with mpdev simulated marketplace deployments.

These steps assume that you have cd'd to the k8s/rancher directory under the
click-to-deploy repo.

## Ensure you have created an appriately configured GKE Cluster

Per NueVector recommendations you will need at least 3 nodes with 8G RAM and
2 vCPUs to support a stable Rancher deployment.

Ensure that this GKE Cluster is the active cluster.

## Ensure your GKE Cluster is ready for deploying Click-to-Deploy (C2D) Apps

Run make with no arguments to ensure your GKE Cluster is initialised properly
to deploy GKE C2D Applications.

```shell
% make
```

This will install the Application CRD and other pre-requisites.

## Test the rancher-prime-byos chart

Quick and dirty commands used to test the chart:

```shell
% rancher_host=rancher-prime-byos
% rancher_tag=2.7.9-gcmp
% kubectl delete namespace rancher
% make
% make app/build SOURCE_REGISTRY=gcr.io/suse-gce-test RELEASE=${rancher_tag}
% kubectl create namespace rancher
% helm upgrade --install rancher-installer chart/rancher-prime-byos/ \
	--namespace rancher \
	--set rancherHostname=${rancher_host} \
	--set rancherServerURL=https://${rancher_host}/ \
	--set image.pullPolicy=Always \
	--set-string serviceAccount.create=true
	--set rancherReplicas=3 \
	--set-json global.images.rancher_prime_byos='{"repository": "gcr.io/suse-gce-test", "image": "rancher-prime-byos", "tag": "'${rancher_tag}'"}'
```

If you have pushed up test images with a different tag suffix than `-gcmp` then just
update the `rancher_tag` value's suffix to match.

# The following instructions have not yet been validated - correct as needed

## Build the deployer image

Build the deployer image you want to test, specifying the tag associated with
the specific set of Rancher and supporting images as the RELEASE value, e.g.
`2.7.9-gcmp`, and the build target `app/build`, the make command would look
like:

```shell
% make app/build RELEASE=2.7.9-gcmp
```

## Pre-create the deployment namespace

Replace the `rancher` namespace with whatever namespace you plan to use:

```shell
% kubectl create namespace rancher
```

## Run the mpdev install with appropriate parameters

Replace the `2.7.9-gcmp` tag value below with which tag you used as the
RELEASE value when you built the deployer image.

```shell
mpdev install \\
    --deployer=gcr.io/suse-gce-test/rancher-prime-byos/deployer:2.7.9-gcmp \\
    --parameters='{"name": "test-deployment",
                   "namespace": "rancher"}'
```
