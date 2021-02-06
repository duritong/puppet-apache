# manage an apache worker
class apache::worker inherits apache {
  if $facts['os']['name'] == 'CentOS' { include apache::centos::worker }
}
