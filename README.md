# homelab

Basic setup to get a working Kubernetes cluster incl. VMs using libvirt and terraform.

## Prerequisites

- libvirt
- opentofu
- mkisofs (homebrew: dvdrtools)

Optional:

- k0sctl
- direnv

## Usage

### Bootstrapping the cluster

##### Prep

Copy and/or edit the `example.tfvars` (in ./infra/) and `cloud-init` (in ./infra/resources/) files as needed.

If you do not have direnv hooked into your shell, source the env file:

```bash
. .env.example
```

To automatically install required provider plugins:

```bash
tofu -chdir=infra init
```

If you do not want to get prompted by polkit, either run the next steps using `sudo -E` or add your user to the libvirt group:

```bash
sudo usermod -aG libvirt myuser
```

##### Provision the VM(s)

Run:

```bash
tofu -chdir=infra apply -var-file=./example.tfvars
```

Optional: once finished, you can add the created VMs to your `/etc/hosts`:

```bash
tofu -chdir=infra output --raw hosts_entries | sudo tee -a /etc/hosts
```

##### Create a Kubernetes cluster

The previous steps will also have created a ready-to-use Kubernetes cluster config for [k0sctl](https://github.com/k0sproject/k0sctl) that you may apply:

```bash
k0sctl apply --config infra/k0sctl.yaml
```

To get the kubeconfig output:

```bash
k0sctl kubeconfig --config infra/k0sctl.yaml [> ~/.kube/config]
```

### Deploying applications

Install ArgoCD:

```bash
./util/argocd-install.sh
```

Add/edit/remove manifests as desired in `./k8s/argocd/`, then apply them:

```bash
./util/argocd-apply-apps.sh
```

If you want to visit `ArgoCD`'s UI, run:

```bash
./util/argocd-portfwd.sh
```

and visit https://localhost:8080 - authenticate using `admin` and the output of

```bash
./util/argocd-initial-secret.sh [| wl-copy/xclip]
```

### Cleanup

Run 

```bash
tofu -chdir=infra destroy -var-file=./example.tfvars  # or whatever .tfvars file you used to create the VMs
```

Optionally, check and remove entries in `/etc/hosts` and `$HOME/.ssh/known_hosts`.

## Known issues

#### libvirt storage pool

An image storage pool is expected, if it is missing, run the following as root:

```bash
virsh pool-define-as default dir --target "/mnt/mypath/libvirt/images" \
  && virsh pool-build default \
  && virsh pool-start default \
  && virsh pool-autostart default
```

#### networking

Libvirt VMs may have issues using the bridge interface for internet access if
Docker is installed. Edit `/etc/libvirt/network.conf` and set:
```ini
firewall_backend = "iptables"
```
to fix this, or replace Docker with Podman. See [here for more infos](https://bbs.archlinux.org/viewtopic.php?pid=2178694#p2178694).

#### k0sctl apply fails due to ssh key mismatch

```log
not connected: client connect: can't connect: ssh: handshake failed: host key mismatch: knownhosts: key mismatch
```

> This is because you have used the same IP before [...]. The same happens if you try to `ssh root@10.10.10.10`.
> 
> Solution 1 - Remove the keys from `~/.ssh/known_hosts` file:
>
> ```
> $ ssh-keygen -R 10.10.10.10
> $ ssh-keygen -R 10.10.10.11
>```
> 
> Solution 2 - Configure the address range to not use host key checking:
> 
> ```
> # ~/.ssh/config
> Host 10.10.10.*
>   UserKnownHostsFile=/dev/null
> ```
> 
> Solution 3 - Disable host key checking while running k0sctl:
>
> ```
> $ env SSH_KNOWN_HOSTS=/dev/null k0sctl apply --config ./infra/k0sctl.yaml
> ```

Adapted to defaults from [the original comment here](https://github.com/k0sproject/k0sctl/issues/445#issuecomment-1378680320).

