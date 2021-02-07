# whatever is needed for sftponly support
class apache::sftponly {
  if $facts['os']['name'] == 'CentOS' {
    include apache::sftponly::centos
  }
}
