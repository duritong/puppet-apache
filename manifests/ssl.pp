# manifests/ssl.pp

class apache::ssl inherits apache {
  case $operatingsystem {
    centos: { include apache::ssl::centos }
    openbsd: { include apache::ssl::openbsd }
    defaults: { include apache::ssl::base }
  }
  if $use_shorewall {
    include shorewall::rules::http
  }
}
