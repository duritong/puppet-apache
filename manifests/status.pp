# enable apache status page
# manage munin plugins if requested
class apache::status {
  if $::operatingsystem == 'CentOS' {
    include apache::status::centos
  } elsif $::operatingsystem == 'Debian' {
    include apache::status::debian
  }
  if $apache::manage_munin {
    include apache::munin
  }
}

