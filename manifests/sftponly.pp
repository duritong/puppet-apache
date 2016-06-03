# whatever is needed for sftponly support
class apache::sftponly {
  if $::operatingsystem == 'CentOS' {
    include apache::sftponly::centos
  }
}
