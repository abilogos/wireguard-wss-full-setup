#!/bin/bash
#needs server ranges
echo "install a simple dns server for private network internal use. (it will prevent DNS Leak, also provide DNS Caching)"
echo "please provide private Network ipv4 address: (example 10.10.10.0/24)"
read NETWORK_RANGE_4
echo "please provide private Network ipv6 address: (example fd4e:cd6e:5c0e::0/64)"
read NETWORK_RANGE_6

apt-get install unbound unbound-host -y
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache

cat << EOF >> /etc/unbound/unbound.conf
server:

  num-threads: 4

  #Enable logs
  verbosity: 1

  #list of Root DNS Server
  root-hints: "/var/lib/unbound/root.hints"

  #Use the root servers key for DNSSEC
#  auto-trust-anchor-file: "/var/lib/unbound/root.key"

  #Respond to DNS requests on all interfaces
  interface: 0.0.0.0
  max-udp-size: 3072

  #Authorized IPs to access the DNS Server
  access-control: 0.0.0.0/0                 refuse
  access-control: 127.0.0.1                 allow
  access-control: $NETWORK_RANGE_4         allow
  access-control: $NETWORK_RANGE_6         allow

  #not allowed to be returned for public internet  names
  private-address: $NETWORK_RANGE_4

  # Hide DNS Server info
  hide-identity: yes
  hide-version: yes

  #Limit DNS Fraud and use DNSSEC
  harden-glue: yes
  harden-dnssec-stripped: yes
  harden-referral-path: yes

  #Add an unwanted reply threshold to clean the cache and avoid when possible a DNS Poisoning
  unwanted-reply-threshold: 10000000

  #Have the validator print validation failures to the log.
  val-log-level: 1

  #Minimum lifetime of cache entries in seconds
  cache-min-ttl: 1800

  #Maximum lifetime of cached entries
  cache-max-ttl: 14400
  prefetch: yes
  prefetch-key: yes

EOF

chown -R unbound:unbound /var/lib/unbound
systemctl enable --now unbound
