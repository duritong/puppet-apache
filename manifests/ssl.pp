# manifests/ssl.pp

class apache::ssl inherits apache {
  case $operatingsystem {
    centos: { include apache::ssl::centos }
    openbsd: { include apache::ssl::openbsd }
    debian: { include apache::ssl::debian }
    defaults: { include apache::ssl::base }
  }
  if $use_shorewall {
    include shorewall::rules::https
  }
}
