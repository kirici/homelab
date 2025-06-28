# homelab

Basic setup to get a working Kubernetes cluster running on a virtual machine
using libvirt and terraform.

## Usage

Convenience scripts are available in `./util/`. Running `tf-create.sh` is
enough to create a VM with K8s installed. Running `vm-kubeconfig.sh` will
automatically copy the guest's kubeconfig (once ready) to your .kube directory,
adjusting it to be ready for use. Running `argocd-apply-apps.sh` will perform
an initial install of the application manifests in the `./argocd/` directory.

## Known issues

##### libvirt storage pool

An image storage pool is expected, if it is missing, run the following as root:

```bash
virsh pool-define-as default dir --target "/mnt/mypath/libvirt/images" \
  && virsh pool-build default \
  && virsh pool-start default \
  && virsh pool-autostart default

```

##### networking

Libvirt VMs may have issues using the bridge interface for internet access if
Docker is installed. Edit `/etc/libvirt/network.conf` and set:
```ini
firewall_backend = "iptables"
```
to fix this, or replace Docker with Podman. See [here for more infos](https://bbs.archlinux.org/viewtopic.php?pid=2178694#p2178694).
