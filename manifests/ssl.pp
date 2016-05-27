# manifests/ssl.pp
# manage apache with ssl
class apache::ssl {
  case $::operatingsystem {
    'CentOS': { include ::apache::ssl::centos }
    'Debian': { include ::apache::ssl::debian }
    default: { include ::apache::ssl::base }
  }
  if $apache::manage_shorewall {
    include ::shorewall::rules::https
  }
}
