#!/bin/bash
#
# This script is intended to be used for internal testing only, to create the artifacts necessary for 
# testing and deploying this code in a sample GKE cluster.
#
set -xe

PROJECT=${PROJECT:-strapdata-factory}
CLUSTER=${CLUSTER:-lab}
ZONE=${ZONE:-europe-west1-b}
NODES=${NODES:-3}

echo "gke: creating cluster"
gcloud container clusters create $CLUSTER \
    --zone "$ZONE" \
    --project $PROJECT \
    --machine-type "n1-standard-2" \
    --num-nodes "3"
#    --max-nodes "6" \
#    --enable-autoscaling
    

echo "gke: getting credentials"
gcloud container clusters get-credentials $CLUSTER \
   --zone $ZONE \
   --project $PROJECT

# Configure local auth of docker so that we can use regular
# docker commands to push/pull from our GCR setup.
echo "gke: authenticate to gcr"
gcloud auth configure-docker

# Bootstrap RBAC cluster-admin for your user.
# More info: https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control
echo "gke: bootstrap RBAC"
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin --user $(gcloud config get-value account)

echo "gke: starting proxy"
exec nohup kubectl proxy &

# Create google-specific custom resources in the cluster.
echo "gke: create google app crd"
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"


echo "gke: cluster created"

# TO DELETE:
# gcloud beta container clusters delete lab --region europe-west1-b