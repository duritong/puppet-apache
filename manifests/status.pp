# enable apache status page
# manage munin plugins if requested
class apache::status (
  $pwd,
) {
  if $facts['os']['name'] == 'CentOS' {
    include apache::status::centos
  } elsif $facts['os']['name'] == 'Debian' {
    include apache::status::debian
  }
  if $apache::manage_munin {
    class { 'apache::munin':
      pwd => $pwd,
    }
  }
}
