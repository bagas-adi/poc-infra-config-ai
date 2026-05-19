datacenter = "dc1"
data_dir   = "/opt/consul/data"
log_level  = "INFO"

server           = true
bootstrap_expect = 1

bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"

ui_config {
  enabled = true
}

ports {
  http  = 8500
  dns   = 8600
  grpc  = 8502
  serf_lan = 8301
  serf_wan = 8302
  server   = 8300
}

connect {
  enabled = true
}

addresses {
  http = "0.0.0.0"
}
