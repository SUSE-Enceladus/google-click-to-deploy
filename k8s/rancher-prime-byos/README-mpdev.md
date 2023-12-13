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
% kubectl delete namespace rancher
% make
% make app/build SOURCE_REGISTRY=gcr.io/suse-gce-test RELEASE=2.7.9-gcmp
% kubectl create namespace rancher
% helm upgrade --install rancher-installer chart/rancher-prime-byos/ \
	--namespace rancher \
	--set rancherHostname=${rancher_host} \
	--set rancherServerURL=https://${rancher_host}/ \
	--set image.pullPolicy=Always
```

# The following instructions have not yet been validated - DO NOT USE

## Build the deployer image

Build the deployer image you want to test, specifying the tag associated with
the specific set of Rancher and supporting images as the RELEASE value, e.g.
`5.2.1-gcmp`, and the build target `app/build`, the make command would look
like:

```shell
% make app/build RELEASE=2.7.9-gcmp
```

## Pre-create the deployment namespace

Replace the `rancher` namespace with whatever namespace you plan to use:

```shell
% kubectl create namespace rancher
```

## Set the pod-security label (Optional?)

Use the name of the previously created namespace instead of `rancher`.

```shell
% kubectl label namespace rancher \\
    "pod-security.kubernetes.io/enforce=privileged"
```

## Run the mpdev install with appropriate parameters

Replace the `2.7.9-gcmp` tag value below with which tag you used as the
RELEASE value when you built the deployer image.

```shell
mpdev install \\
    --deployer=gcr.io/suse-gce-test/rancher/deployer:2.7.9-gcmp \\
    --parameters='{"name": "test-deployment",
                   "namespace": "rancher"}'
```
