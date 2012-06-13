# manifests/status.pp

class apache::status {
  case $::operatingsystem {
    centos: { include apache::status::centos }
    defaults: { include apache::status::base }
  }
  if $apache::manage_munin {
    include munin::plugins::apache
  }
}

