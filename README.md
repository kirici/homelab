# Homelab: Rocky 9 + cloud-init + KubeOne on libvirt

`terragrunt apply` creates the network, base image, three Rocky 9 VMs and a KubeOne manifest whose hosts
are rendered from the `nodes` output (`.state/kubeone.yaml`). Kubernetes is installed separately with
KubeOne, so the two steps can be folded together later.

## Host setup (Fedora, fish)

```fish
sudo dnf install -y \
    qemu-kvm \
    libvirt-daemon-driver-qemu \
    libvirt-daemon-driver-network \
    libvirt-daemon-driver-storage-core \
    libvirt-daemon-config-network \
    libvirt-client \
    virt-install

sudo systemctl enable --now virtqemud.socket virtnetworkd.socket virtstoragend.socket
sudo usermod -aG libvirt $USER
```

Log out and in again, then check `virsh -c qemu:///system list`. You also need an SSH key at
`~/.ssh/id_ed25519` (or set `K8S_SSH_KEY` and `K8S_SSH_PUBKEY`).

## Usage

```fish
mise install
mise run plan
mise run apply            # VMs and .state/kubeone.yaml
mise run cluster:apply    # waits for SSH, installs k8s, writes .state/kubeconfig
mise run cluster:post-install
```

Layout and sizing live in `live/homelab/cluster.hcl`. Cluster settings (versions, Cilium options) live in
`kubeone/kubeone.base.yaml`; the generated manifest is never edited by hand.

## Open topics

- Tailscale or Headscale on the host as bridge, bastion and possibly the LoadBalancer entrypoint, with a
  persistent endpoint. Not designed yet. The NAT network is host-reachable only until then.
- `lan_bridge` in `cluster.hcl` adds a second NIC on an existing host bridge, if you want one before that.
- Folding `cluster:apply` into a terragrunt unit later.
