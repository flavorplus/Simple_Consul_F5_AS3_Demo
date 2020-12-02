#!/bin/bash

mkdir -p /config/cloud
cat << 'EOF' > /config/cloud/runtime-init-conf.yaml
---
runtime_parameters: []
pre_onboard_enabled:
  - name: provision_rest
    type: inline
    commands:
      - /usr/bin/setdb provision.extramb 500
      - /usr/bin/setdb restjavad.useextramb true
      - /usr/bin/setdb setup.run false
post_onboard_enabled: []
extension_packages:
  install_operations:
  - extensionType: as3
    extensionVersion: 3.24.0
    extensionUrl: https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm
  - extensionType: do
    extensionVersion: 1.16.0
extension_services:
  service_operations:
  - extensionType: do
    type: inline
    value:
      schemaVersion: 1.0.0
      class: Device
      async: true
      Common:
        class: Tenant
        myDns:
          class: DNS
          nameServers:
          - 8.8.8.8
        myNtp:
          class: NTP
          servers:
          - 0.pool.ntp.org
          timezone: Europe/Amsterdam
        admin:
          class: User
          userType: regular
          password: ${password}
          shell: bash

  - extensionType: as3
    type: inline
    value:
      class: AS3
      action: deploy
      persist: true
      declaration:
          class: ADC
          schemaVersion: 3.24.0
          id: Consul_SD
          Consul_SD:
            class: Tenant
            Nginx:
              class: Application
              template: http
              serviceMain:
                class: Service_HTTP
                virtualPort: 8080
                virtualAddresses:
                  - "${f5_public_ip}"
                pool: web_pool
                persistenceMethods: []
                profileMultiplex:
                  bigip: "/Common/oneconnect"
              web_pool:
                class: Pool
                monitors:
                  - http
                members:
                  - servicePort: 80
                    addressDiscovery: consul
                    updateInterval: 5
                    uri: http://${consul_private_ip}:8500/v1/health/service/nginx?passing
                    jmesPathQuery: "[*].{id:Node.Address,ip:{private:Node.Address,public:Node.Address},port:Service.Port}"
EOF

source /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

for i in {1..30}; do
    curl -fv --retry 1 --connect-timeout 5 -L "https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.1.0/dist/f5-bigip-runtime-init-1.1.0-1.gz.run" -o "/var/config/rest/downloads/f5-bigip-runtime-init-1.1.0-1.gz.run" && break || sleep 10
done
bash /var/config/rest/downloads/f5-bigip-runtime-init-1.1.0-1.gz.run -- '--cloud aws'

f5-bigip-runtime-init --config-file /config/cloud/runtime-init-conf.yaml