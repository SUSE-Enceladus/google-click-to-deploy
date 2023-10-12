# Overview

NeuVector Prime is a 100% open-source Kubernetes container security
platform built for enterprise-grade environments. Supported by a
strong community of users, NeuVector provides full lifecycle container
security from build, pipeline, registry to production. NeuVector
enables you to run Kubernetes SECURELY everywhere - from cloud to
on-prem or at the edge. In addition to end-to-end vulnerability and
compliance scanning, NeuVector provides unique runtime protection
which combines a layer7 container firewall with workload process/file
protections. The network protection of NeuVector uses deep packet
inspection (DPI) to monitor and block network threats, segmentation
violations, and unauthorized ingress or egress connections. This
technology enables data leak protection (DLP) rules, web application
firewall (WAF) rules, api security validation, and is compatible with
service meshes such as istio and AWS App Mesh. NeuVector is a
cloud-native solution which deploys easily on GKS to protect workloads
and hosts from vulnerability exploits and zero-day attacks. The
deployment is a set of containers (manager, controller, enforcer,
scanner) which can be managed through the console or rest API. This
deployment configures a GKS load balancer service to expose the
manager console. For more information on NeuVector see the project
documentation at https://open-docs.neuvector.com/.


## About Google Click to Deploy

Popular open source software stacks on Kubernetes packaged by Google and made
available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Neuvector-prime to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/sample-app).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/SUSE-Enceladus/google-click-to-deploy&cloudshell_git_branch=doc-update&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/neuvector)
>>>>>>> Stashed changes

#### Set up command line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-   [docker](https://docs.docker.com/install/)
-   [openssl](https://www.openssl.org/)
-   [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a cluster from the command line. If you already have a cluster that you
want to use, this step is optional.

```shell
export CLUSTER=neuvector-cluster
export ZONE=us-central1-c
export NUM_NODES=3
gcloud container clusters create "$CLUSTER" \
--zone "$ZONE" \
--num-nodes="$NUM_NODES" \
--enable-ip-alias \
--metadata disable-legacy-endpoints=true \
--cluster-version "1.26.6-gke.1700" \
--no-enable-basic-auth \
--release-channel "None" \
--machine-type "e2-standard-2" \
--image-type "COS_CONTAINERD" \
--disk-type "pd-balanced" \
--disk-size "100" \
--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--no-enable-intra-node-visibility \
--default-max-pods-per-node "110" \
--security-posture=standard \
--workload-vulnerability-scanning=disabled \
--no-enable-master-authorized-networks \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
--enable-autoupgrade \
--enable-autorepair \
--max-surge-upgrade 1 \
--max-unavailable-upgrade 0 \
--no-enable-managed-prometheus \
--enable-shielded-nodes \
--enable-l4-ilb-subsetting \
--node-locations "$ZONE" \
--network "projects/suse-gce-test/global/networks/esampson-test" \
--subnetwork "projects/suse-gce-test/regions/us-central1/subnetworks/esampson-test"
```

#### Configure kubectl to connect to the cluster

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

```shell
git clone --recursive -b doc-update https://github.com/SUSE-Enceladus/google-click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once for each cluster.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `neuvctor` directory:

```shell
cd google-click-to-deploy/k8s/neuvector
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=neuvector-prime
export NV_NAME_SPACE=neuvector
```

Set up the image tag:

It is advised to use stable image reference which you can find on
[Marketplace Container Registry](https://marketplace.gcr.io/google/neuvector-prime).
Example:

```shell
export TAG="TBD"
```

Alternatively you can use short tag which points to the latest image for selected version.
> Warning: this tag is not stable and referenced image might change over time.

```shell
export TAG="TBD"
```

Configure the container images:

```shell
export IMAGE_NEUVECTOR-PRIME="marketplace.gcr.io/google/neuvector-prime"
export IMAGE_NEUVECTOR-PRIME_INIT="marketplace.gcr.io/google/neuvector-prime/init"
```

#### Create a and set up namespace in your Kubernetes cluster

If you use a different namespace than `default`, run the command below to create
a new namespace:

```shell
# create namespace
kubectl create namespace ${NV_NAME_SPACE}

# label and set priv on namespace
kubectl label namespace ${NV_NAME_SPACE} "pod-security.kubernetes.io/enforce=privileged"


# install secret
gsutil cp gs://cloud-marketplace-tools/reporting_secrets/fake_reporting_secret.yaml /tmp/.
echo "metadata: {name: fake-reporting-secret}" >> /tmp/fake_reporting_secret.yaml
kubectl apply -n ${NV_NAME_SPACE} -f /tmp/fake_reporting_secret.yaml

# set admin account secret
PASSWORD=Admin1234 envsubst <userinitcfg.yaml.template >/tmp/userinitcfg.yaml

kubectl create secret generic neuvector-init --from-file=/tmp/userinitcfg.yaml -n ${NV_NAME_SPACE}

```

### Get/create helm chart
```shell
./tools/set-up-chart https://github.com/SUSE-Enceladus/neuvector-helm-gks.git payg neuvector-prime



#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/neuvector-prime \
  --name "$APP_INSTANCE_NAME" \
  --namespace "$NAMESPACE" \
:
:
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the GCP Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view your app, open the URL in your browser.

# Using the app

You can get the IP addresses for Neuvector Console from:

  SERVICE_IP=$(kubectl get svc --namespace ${NV_NAME_SPACE} neuvector-service-webui -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
  echo https://$SERVICE_IP:8443

Use browser to access console at IP and port returned.



## Using the Google Cloud Platform Console

1.  In the GCP Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1.  From the list of applications, click **Neuvector-prime**.

1.  On the Application Details page, click **Delete**.

## Using the command line

1.  Navigate to the `neuvector-prime` directory.

    ```shell
    cd click-to-deploy/k8s/neuvector
    ```

1.  Run the `kubectl delete` command:

    ```shell
    kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
    ```

Optionally, if you don't need the deployed application or the Kubernetes Engine
cluster, delete the cluster using this command:

```shell
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```

