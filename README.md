# homelab

Basic setup to get a working Kubernetes cluster incl. VMs using libvirt and terraform.

## Prerequisites
---
- libvirt
- opentofu

Optional:

- k0sctl

## Usage
---
### Bootstrapping the cluster

Edit [example.tfvars](./infra/example.tfvars) and [cloud-init](./infra/resources/cloud-init.yaml) as needed.

Then, run:

```bash
sudo ./util/tf-create.sh
```

Once finished, you can add the created VMs to your `/etc/hosts`:

```bash
tofu -chdir=infra output --raw hosts_entries | sudo tee -a /etc/hosts
```

The previous apply step will also have createc a ready-to-use Kubernetes cluster config for [k0sctl](https://github.com/k0sproject/k0sctl) that you may apply:

```bash
k0sctl apply --config ./infra/k0sctl.yaml
```

And grab the resulting kubeconfig like so:

```bash
k0sctl kubeconfig --config ./infra/k0sctl.yaml [> ~/.kube/config]
```

---
### Deploying applications

Install ArgoCD:

```bash
./util/argocd-install.sh
```

Add/edit/remove manifests as desired in `./k8s/argocd/`, then apply them:

```bash
./util/argocd-apply-apps.sh
```

If you want to visit `ArgoCD`'s UI, you may also run:

```bash
./util/argocd-portfwd.sh
```

and visit https://localhost:8080 - authenticate using `admin` and the output of

```bash
./util/argocd-initial-secret.sh [| wl-copy/xclip]
```

## Cleanup

Run 

```bash
sudo ./util/tf-destroy.sh
```

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

##### k0sctl apply fails

```log
 - [SSH] $NODE_IP: retrying aborted
not connected: client connect: can't connect: ssh: handshake failed: host key mismatch: knownhosts: key mismatch
```

Couple of options:

Removing the `known_hosts` entry

```bash
ssh-keygen -R $NODE_IP
```

Or(/and) pointing `k0sctl` to some other file/the void:

```bash
SSH_KNOWN_HOSTS=/dev/null k0sctl apply --config ./infra/k0sctl.yaml
```
