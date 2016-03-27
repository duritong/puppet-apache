# manage ssl on centos
class apache::ssl::centos inherits apache::ssl::base {
  package{'mod_ssl':
    ensure  => present,
    require => Package['apache'],
    before  => Service['httpd'],
  } -> apache::config::global{
    'ssl.conf':;
    '00-listen-ssl.conf':
      ensure => absent;
  }
}
