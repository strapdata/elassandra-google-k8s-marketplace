#!/bin/bash
#
# This script is intended to be used for internal testing only, to create the artifacts necessary for 
# testing and deploying this code in a sample GKE cluster.
#
PROJECT=neo4j-k8s-marketplace-public
CLUSTER=lab
ZONE=us-central1-a
NODES=3
API=beta

gcloud beta container clusters create $CLUSTER \
    --zone "$ZONE" \
    --project $PROJECT \
    --machine-type "n1-standard-1" \
    --num-nodes "3" \
    --max-nodes "6" \
    --enable-autoscaling
    
gcloud container clusters get-credentials $CLUSTER \
   --zone $ZONE \
   --project $PROJECT

# Configure local auth of docker so that we can use regular
# docker commands to push/pull from our GCR setup.
gcloud auth configure-docker

# Bootstrap RBAC cluster-admin for your user.
# More info: https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin --user $(gcloud config get-value account)

exec nohup kubectl proxy &

# Create google-specific custom resources in the cluster.
kubectl apply -f vendor/marketplace-k8s-app-tools/crd/app-crd.yaml

# TO DELETE
# helm delete --purge mycluster