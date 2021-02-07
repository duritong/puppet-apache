# manifests/ssl.pp
# manage apache with ssl
class apache::ssl {
  case $facts['os']['name'] {
    'CentOS': { include apache::ssl::centos }
    'Debian': { include apache::ssl::debian }
    default: { include apache::ssl::base }
  }
  if $apache::use_firewall {
    include firewall::rules::https
  }
}
