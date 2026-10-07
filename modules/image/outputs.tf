output "pool_name" {
  value = libvirt_pool.this.name
}

output "base_volume_path" {
  value = libvirt_volume.base.path
}
