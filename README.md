# homelab

Basic setup to get a working Kubernetes cluster running on a virtual machine
using libvirt and terraform.

## Usage

Convenience scripts are available in `./util/`. Running `tf-create.sh` is
enough to create a VM with K8s installed. Running `vm-kubeconfig.sh` will
automatically copy the guest's kubeconfig (once ready) to your .kube directory,
adjusting it to be ready for use. Running `argocd-apply-apps.sh` will perform
an initial install of the application manifests in the `./argocd/` directory.
