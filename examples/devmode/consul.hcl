{
  "bind_addr": "{{host_ip_address}}",
  "client_addr": "{{host_ip_address}}",
  "datacenter": "{{datacenter}}",
  "data_dir": "/tmp/consul",
  "log_level": "DEBUG",
  "enable_debug": true,
  "node_name": "consul-devagent",
  "server": true,
  "bootstrap_expect": 1,
  "ui": true,
  "leave_on_terminate": false,
  "skip_leave_on_interrupt": true,
  "rejoin_after_leave": true
}
