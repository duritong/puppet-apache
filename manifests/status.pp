# enable apache status page
# manage munin plugins if requested
class apache::status {
  case $::operatingsystem {
    centos: { include apache::status::centos }
    defaults: { include apache::status::base }
  }
  if $apache::manage_munin {
    include apache::munin
  }
}

