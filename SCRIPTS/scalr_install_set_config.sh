#!/bin/bash

# take the template file and substitute the IPs

exec 1>/var/tmp/$(basename $0).log

exec 2>&1

abort () {
  echo "ERROR: Failed with $1 executing '$2' @ line $3"
  exit $1
}

trap 'abort $? "$STEP" $LINENO' ERR


DOMAIN_NAME=$1
shift
DB_M=$1

STEP="Create config with cat"

cat << ! > /var/tmp/scalr-server.rb
enable_all false
product_mode :iacp
# Mandatory SSL
# Update the below settings to match your FQDN and where your .key and .crt are stored
proxy[:ssl_enable] = true
proxy[:ssl_redirect] = true
proxy[:ssl_cert_path] = "/etc/scalr-server/organization.crt"
proxy[:ssl_key_path] = "/etc/scalr-server/organization.key"
routing[:endpoint_host] = "$DOMAIN_NAME"
routing[:endpoint_scheme] = "https"
#Add if you have a self signed cert, update with the proper location if needed
#ssl[:extra_ca_file] = "/etc/scalr-server/rootCA.pem"
#Add if you require a proxy, it will be used for http and https requests
#http_proxy "http://user:*****@my.proxy.com:8080"
#If a no proxy setting is needed, you can define a domain or subdomain like so: no_proxy=example.com,domain.com . The following setting would not work: *.domain.com,*example.com
#no_proxy example.com
#If you are using an external database service or separating the database onto a different server.
app[:mysql_scalr_host] = "$DB_M"
app[:mysql_scalr_port] = 3306
####The following is only needed if you want to use a specific version of Terraform that Scalr may not included yet.####
#app[:configuration] = {
#:scalr => {
#  "tf_worker" => {
#      "default_terraform_version"=> "0.12.20",
#      "terraform_images" => {
#          "0.12.10" => "hashicorp/terraform:0.12.10",
#          "0.12.20" => "hashicorp/terraform:0.12.20"
#      }
#    }
#  }
#}
!
