log_level = "DEBUG"
enable_debug = true
datacenter = "{{datacenter}}"
data_dir = "/tmp/nomad-devagent"

name = "nomad-devagent"

bind_addr = "0.0.0.0"

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
  options = {
    "driver.raw_exec.enable" = "1"
  }
}

server {
  enabled          = true
  bootstrap_expect = 1
  num_schedulers   = 1
}

consul {
  address = "{{host_ip_address}}:8500"
}
