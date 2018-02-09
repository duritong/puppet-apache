# manage ssl on centos
class apache::ssl::centos inherits apache::ssl::base {
  package{'mod_ssl':
    ensure  => present,
    require => Package['apache'],
    before  => Service['apache'],
  } -> apache::config::global{
    'ssl.conf':;
    '00-listen-ssl.conf':
      content => template('apache/conf/ssl_listen.erb');
  }
}
