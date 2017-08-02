### debian
class apache::debian inherits apache::base {
  Package['apache'] {
    name => 'apache2',
  }
  File['htpasswd_dir'] {
    group  => 'www-data',
  }
  file { 'apache_main_config':
    path    => "${apache::config_dir}/apache2.conf",
    source  => [ "puppet:///modules/site_apache/config/Debian.${::lsbdistcodename}/${::fqdn}/apache2.conf",
                "puppet:///modules/site_apache/config/Debian/${::fqdn}/apache2.conf",
                "puppet:///modules/site_apache/config/Debian.${::lsbdistcodename}/apache2.conf",
                'puppet:///modules/site_apache/config/Debian/apache2.conf',
                "puppet:///modules/apache/config/Debian.${::lsbdistcodename}/${::fqdn}/apache2.conf",
                "puppet:///modules/apache/config/Debian/${::fqdn}/apache2.conf",
                "puppet:///modules/apache/config/Debian.${::lsbdistcodename}/apache2.conf",
                'puppet:///modules/apache/config/Debian/apache2.conf' ],
    require => Package['apache'],
    notify  => Service['apache'],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
  apache::config::global{ 'charset': }
  apache::config::global{ 'security': }
  file { 'default_debian_apache_vhost':
    ensure => absent,
    path   => '/etc/apache2/sites-enabled/000-default',
  }
}

