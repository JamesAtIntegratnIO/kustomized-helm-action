#!/bin/bash
set -eo pipefail

# Check if required variables are set
for var in DIRS INCLUDE_CRDS; do
  if [ -z "${!var}" ]; then
    echo "Error: $var is not set. Please set it before running the script."
    exit 1
  fi
done

IFS=',' read -r -a dir_array <<<"${DIRS}"
for dir in "${dir_array[@]}"; do
  if [ -d "$dir" ]; then
    echo "Processing directory: $dir"
    cd $dir
    cd ../../base
    if [ -f Chart.yaml ]; then
      echo "Chart.yaml found in the base directory"
      cd $dir
      BASE_NAMESPACE=$(cat ../../base/kustomization.yaml | yq e '.namespace // "default"' -)
      NAMESPACE=$(cat kustomization.yaml | yq e ".namespace // \"$BASE_NAMESPACE\"" -)
      echo "Building Helm dependencies for the base directory"
      helm dependency build ../../base
      echo "Creating values.yaml files"
      touch ../../base/values.yaml
      touch values.yaml
      echo "Generating Helm template"
      if [ $INCLUDE_CRDS = true ]; then
        HELM_CMD="helm template \
                --release-name ${NAMESPACE} \
                ../../base \
                -f ../../base/values.yaml \
                --include-crds \
                -f values.yaml > helm-all.yaml"
      else
        HELM_CMD="helm template \
                --release-name ${NAMESPACE} \
                ../../base \
                -f ../../base/values.yaml \
                -f values.yaml > helm-all.yaml"
      fi
      eval $HELM_CMD
    fi

    cd $dir
    echo "Building Kubernetes manifests using kustomize"
    if ! kustomize build --enable-helm . -o ./all.yaml; then
      echo "Error: Failed to build Kubernetes manifests using kustomize."
      exit 1
    fi
    git add all.yaml
  fi
  cd $GITHUB_WORKSPACE
done
