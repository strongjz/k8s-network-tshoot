#!/usr/bin/env bash


if [ -n "$DEBUG" ]; then
	set -x
fi

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE}") && pwd -P)
K8S_VERSION="${K8S_VERSION:-v1.26.3@sha256:61b92f38dff6ccc29969e7aa154d34e38b89443af1a2c14e6cfbd2df6419c66f}"
CILUM_VERSION="${CILIUM_VERSION:-1.15.1}"

if ! command -v kind &> /dev/null; then
  echo "kind is not installed"
  echo "Use a package manager (i.e 'brew install kind') or visit the official site https://kind.sigs.k8s.io"
  exit 1
fi

if ! command -v docker &> /dev/null; then
  echo "docker is not installed"
  echo "Use a package manager (i.e 'brew install kind') or visit the official site https://kind.sigs.k8s.io"
  exit 1
fi

if ! command -v cilium &> /dev/null; then
  echo "cilium is not installed"
  echo "Please see https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/ for cilium install"
  exit 1
fi

if ! command -v kubectl &> /dev/null; then
  echo "Please install kubectl 1.24.0 or higher"
  exit 1
fi

if ! command -v helm &> /dev/null; then
  echo "Please install helm"
  exit 1
fi

function ver { printf "%d%03d%03d" $(echo "$1" | tr '.' ' '); }

HELM_VERSION=$(helm version 2>&1 | cut -f1 -d"," | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') || true
echo "Helm Version installed $HELM_VERSION"
if [[ $(ver "$HELM_VERSION") -lt $(ver "3.10.0") ]]; then
  echo "Please upgrade helm to v3.10.0 or higher"
  exit 1
fi

KUBE_CLIENT_VERSION=$(kubectl version --client -oyaml 2>/dev/null | grep "minor:" | awk '{print $2}' | tr -d '"') || true
if [[ ${KUBE_CLIENT_VERSION} -lt 24 ]]; then
  echo "Please update kubectl to 1.24.2 or higher"
  exit 1
fi

KIND_CLUSTER_NAME="cilium-kind"

if ! kind get clusters -q | grep -q ${KIND_CLUSTER_NAME}; then
  echo "[dev-env] creating Kubernetes cluster with kind"
  kind create cluster --name ${KIND_CLUSTER_NAME} --image "kindest/node:${K8S_VERSION}" --config "${DIR}"/kind.yaml
else
  echo "[dev-env] using existing Kubernetes kind cluster"
fi

kind export kubeconfig --name ${KIND_CLUSTER_NAME}

## helm all the things
helm repo add cilium https://helm.cilium.io/

## grab it locally
docker pull quay.io/cilium/cilium:v"${CILUM_VERSION}"

## load cilium onto kind cluster
kind load docker-image quay.io/cilium/cilium:v"${CILUM_VERSION}"

## install cilium via helm chart
echo "Helm install on ${KIND_CLUSTER_NAME} version ${CILUM_VERSION}"
helm install cilium cilium/cilium --version "${CILUM_VERSION}" \
   --namespace kube-system \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

cilium status --wait   