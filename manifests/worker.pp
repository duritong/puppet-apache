# manage an apache worker
class apache::worker inherits apache {
  if $::operatingsystem == 'CentOS' { include ::apache::centos::worker }
}
