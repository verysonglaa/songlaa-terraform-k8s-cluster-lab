# Songlaa Kubernetes Training Cluster Setup with Terraform

## Overview

This setup provisions a Kubernetes Cluster to be used with our trainings.

We use [Hetzner](https://www.hetzner.com/cloud) as our cloud provider and [RKE2](https://docs.rke2.io/) to create the kubernetes cluster. [Kubernetes Cloud Controller Manager for Hetzner Cloud](https://github.com/hetznercloud/hcloud-cloud-controller-manager) to provision lobalancer from a Kubernetes service (type `Loadbalancer`) objects and also configure the networking & native routing for the Kubernetes cluster network traffic.

In order to deploy our songlaa Kubernetes Cluster the following steps are necessary:

1. Terraform to deploy base infrastructure
   * VM's for controlplane and worker nodes
   * Network
   * Loadbalancer for Kubernetes API and RKE2
   * Firewall
   * Hetzner Cloud Controller Manager for the Kubernetes Cluster Networking
2. Terraform to deploy and then bootstrap ArgoCD using our [training-setup](https://github.com/verysonglaa/training-setup)
3. ArgoCD to deploy resources student/user resources and other components like
   * Storage Provisioner (hcloud csi, longhorn)
   * Ingresscontroller
   * Cert-Manager
   * etc

## Docker and Kubernetes Training Changes
Repo Should be public because of argo.

### Todo

* Create Cloudflare and Hetzner Tokens and put them into prod.tfvars
* Cluster size: ca. 3 Students/per Hosts
* add students e-mails to scripts-4-student-communication/emails.txt


Plain Container:
* enable-dind
* apply kyverno policy "privileged containers"

Plain Kubernetes:
* disable-dind
* apply kyverno policy "privileged containers"


Kubernetes Intro:

* enable-dind
* enable docker-rootless
* apply kyverno policy "privileged containers - exluded images"

Kubernetes Security:

* enable-dind
* apply kyverno policy "privileged containers"

then run deliver/deploy/deploy.sh

### Components

#### argocd

ArgoCD is used to deploy components (e.g.) onto the cluster. ArgoCD is also used for the training itself.

There is a local `admin` account. The password can be extracted with `terraform output argocd-admin-password`

Each student/user also get a local account.

#### external-dns

We use external dns to add records to cloudflare.

#### cert-manager

[Cert Manager](https://cert-manager.io/) is used to issue Certificates (Let's Encrypt).
The [ACME Webhook for the hosttech DNS API](https://github.com/piccobit/cert-manager-webhook-hosttech) is used for `dns01` challenges with our DNS provider.

The following `ClusterIssuer` are available:

* `letsencrypt-prod-songlaa`: for dns01 challenge using cloudflare provider. The api-token is stored in cert-manager namespace

#### Hetzner Kubernetes Cloud Controller Manager

The [Kubernetes Cloud Controller Manager for Hetzner Cloud](https://github.com/hetznercloud/hcloud-cloud-controller-manager) is deployed and allows to provision LoadBalancer based on Services with type `LoadBalancer`.
The Cloud Controller Manager is also resposible to create all the necessary routes between the Kubernete Nodes. See [Network Support](https://github.com/hetznercloud/hcloud-cloud-controller-manager#networks-support) for details.

#### Hetzner CSI

To provision storage we use [Hetzner CSI Driver](https://github.com/hetznercloud/csi-driver).

The StorageClass `hcloud-volumes` is available. Be aware, `hcloud-volumes` are provisioned at our cloud provider and do cost. Furthermore we have [limits](https://docs.hetzner.com/cloud/volumes/faq/#is-there-a-limit-on-the-number-of-attached-volumes) ou how much storage we can provision or more precise, attache to a VM.

#### Ingresscontroller: haproxy

[haproxy](https://github.com/haproxytech/helm-charts/tree/main/kubernetes-ingress) is used as ingress controller. `haproxy` is the default IngressClass

#### Longhorn

As our Kubernetes Nodes have enough local disk available, we use [longhorn](https://longhorn.io/) as a additional storage solution. The `longhorn` storageclass is set as the default storage class.

## Training Environment

The training environment contains the following per student/user:

* Credentials
* All necessary namespaces
* RBAC to access the namespaces
* a [Webshell](https://github.com/verysonglaa/webshell-env) per student/user.

It is deployed with ArgoCD using ApplicationSets. The ApplicationSets are deployed with Terraform

### Access to the training environment

There is a Welcome page deployed at https://welcome.${cluster_name}.{cluster_domain} which contains a list for each student/user with the URL for the Webshell and also credentials.

## Usage

create a prod.tfvars and run deliver/deploy/deploy.sh

## Troubleshooting

The personal ssh public key is added so just ssh to the public ip with root, kubectl is available /var/lib/rancher/rke2/bin.

```bash
server1=$(jq -r '.resources[] | select(.type == "hcloud_server") | .instances[0].attributes.ipv4_address' terraform.tfstate | head -1)
ssh root@$server1
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/var/lib/rancher/rke2/bin
kubectl get pods --all-namespaces
helm ls --all-namespaces
````

<https://docs.rke2.io/cluster_access>

```bash
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/var/lib/rancher/rke2/bin
kubectl get pods --all-namespaces
helm ls --all-namespaces

export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
/var/lib/rancher/rke2/bin/crictl ps
```
