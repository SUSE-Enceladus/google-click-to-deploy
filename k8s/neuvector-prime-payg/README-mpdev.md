# Interim instructions for working with mpdev testing

Basic steps to get things working with mpdev simulated marketplace deployments.

These steps assume that you have cd'd to the k8s/neuvector directory under the
click-to-deploy repo.

## Ensure you have created an appriately configured GKE Cluster

Per NueVector recommendations you will need at least 3 nodes with 8G RAM and
2 vCPUs to support a stable NeuVector deployment.

Ensure that this GKE Cluster is the active cluster.

## Ensure your GKE Cluster is ready for deploying Click-to-Deploy (C2D) Apps

Run make with no arguments to ensure your GKE Cluster is initialisaed properly.

```shell
% make
```

## Build the deployer image

Build the deployer image you want to test, specifying the tag associated with
the specific set of NeuVector and supporting images as the RELEASE value, e.g.
`5.2.1-gcmp`, and the build target `app/build`, the make command would look
like:

```shell
% make app/build RELEASE=5.2.1-gcmp
```

## Pre-create the deployment namespace

Replace the `neuvector` namespace with whatever namespace you plan to use:

```shell
% kubectl create namespace neuvector
```

## Pre-create the userinitcfg.yaml secret

Generate a userinitcfg.yaml file and use it to create the `userinitcfg.yaml`
secret, replacing `Admin1234` with your actual password, and the `neuvector`
with the namespace created previously:

```shell
% env PASSWORD=Admin1234 envsubst <userinitcfg.yaml.template >/tmp/userinitcfg.yaml
% kubectl create secret generic neuvector-init \\
    --from-file=/tmp/userinitcfg.yaml -n neuvector
```

## Set the pod-security label (Optional?)

Use the name of the previously created namespace instead of `neuvector`.

```shell
% kubectl label namespace neuvector \\
    "pod-security.kubernetes.io/enforce=privileged"
```

## Run the mpdev install with appropriate parameters

Replace the `5.2.1-gcmp` tag value below with which tag you used as the
RELEASE value when you built the deployer image.

```shell
mpdev install \\
    --deployer=gcr.io/suse-gce-test/neuvector/deployer:5.2.1-gcmp \\
    --parameters='{"name": "test-deployment",
                   "namespace": "neuvector",
		   "ubbagent.reportingSecretName": \\
		       "gs://cloud-marketplace-tools/reporting_secrets/fake_reporting_secret.yaml"}'
```
