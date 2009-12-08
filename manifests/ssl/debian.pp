class apache::ssl::debian inherits apache::ssl::base {
    line { 'apache_debian_ssl_port':
        file => "${apache::debian::config_dir}/ports.conf",
        line => "Listen 443",
        ensure => present,
        require => Package['apache'],
        notify => Service['apache'],
    }
}
