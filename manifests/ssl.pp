# manifests/ssl.pp

class apache::ssl inherits apache {
    case $operatingsystem {
        centos: { include apache::ssl::centos }
        gentoo: { include apache::ssl::gentoo }
        defaults: { include apache::ssl::base }
    }
}

class apache::ssl::base {}


### distribution specific classes

### centos
class apache::ssl::centos inherits apache::ssl::base {
    package { 'mod_ssl':
        name => 'mod_ssl',
        ensure => present,
        require => Package[apache],
    }
    apache::config::file{ 'ssl.conf': }
    apache::config::file{ 'ssl_defaults.inc': }
    apache::vhost::file{ '0-default_ssl.conf': }
}

### gentoo
class apache::ssl::gentoo inherits apache::ssl::base {
    apache::module::file { '00_default_settings': }
    apache::module::file { '00_error_documents': }
    apache::vhost::file { '00_default_ssl_vhost': }
}
