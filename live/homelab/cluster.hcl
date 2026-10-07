# Single source of truth for the cluster layout. Units read it with read_terragrunt_config(), so the DHCP
# reservations in `network` and the VMs in `nodes` can never drift apart.

locals {
  cluster_name = "homelab"
  libvirt_uri  = "qemu:///system"

  # Dedicated pool under the stock images directory so SELinux file contexts already match.
  pool_name = "k8s"
  pool_path = "/var/lib/libvirt/images/k8s"

  # Rocky publishes only a moving "latest" name per release. The base volume is downloaded once, so existing
  # nodes are unaffected, but a fresh apply on another day can pull a newer point release. Swap in a dated
  # file name from the mirror's directory listing if you need reproducible rebuilds.
  image_name = "rocky-9-base.qcow2"
  image_url  = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"

  # Default account baked into the Rocky cloud image. cloud-init only adds the SSH key to it.
  ssh_user = "rocky"

  network_name = "k8s"
  bridge_name  = "virbr-k8s"
  cidr         = "10.5.0.0/24"

  # Name of an existing host bridge (for example "br0") to give every node a second NIC on your LAN.
  # null keeps the cluster on the isolated NAT network only.
  lan_bridge = null

  ssh_public_key       = trimspace(file(pathexpand(get_env("K8S_SSH_PUBKEY", "~/.ssh/id_ed25519.pub"))))
  ssh_private_key_file = pathexpand(get_env("K8S_SSH_KEY", "~/.ssh/id_ed25519"))

  # IPs stay below .200 because the Cilium LB pool in kubeone/manifests claims .200-.250.
  nodes = {
    cp-1 = {
      role       = "control_plane"
      ip         = "10.5.0.10"
      mac        = "52:54:00:5a:00:10"
      vcpu       = 2
      memory_mib = 4096
      disk_gib   = 20
    }
    worker-1 = {
      role       = "worker"
      ip         = "10.5.0.21"
      mac        = "52:54:00:5a:00:21"
      vcpu       = 2
      memory_mib = 8192
      disk_gib   = 40
    }
    worker-2 = {
      role       = "worker"
      ip         = "10.5.0.22"
      mac        = "52:54:00:5a:00:22"
      vcpu       = 2
      memory_mib = 8192
      disk_gib   = 40
    }
  }
}
