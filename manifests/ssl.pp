# manifests/ssl.pp

class apache::ssl inherits apache {
    case $operatingsystem {
        centos: { include apache::ssl::centos }
        gentoo: { include apache::ssl::gentoo }
        openbsd: { include apache::ssl::openbsd }
        defaults: { include apache::ssl::base }
    }
}

class apache::ssl::base {
    apache::config::file{ 'ssl_defaults.inc': }
    apache::vhost::file{ '0-default_ssl': }
}


### distribution specific classes

### centos
class apache::ssl::centos inherits apache::ssl::base {
    package { 'mod_ssl':
        name => 'mod_ssl',
        ensure => present,
        require => Package[apache],
    }
    apache::config::file{ 'ssl.conf': }
}

### gentoo
class apache::ssl::gentoo inherits apache::ssl::base {}

class apache::ssl::openbsd inherits apache::openbsd {
    include apache::ssl::base

    Line['enable_apache_on_boot']{
        ensure => 'absent',
    }
    line{'enable_apachessl_on_boot':
        file => '/etc/rc.conf.local',
        line => 'httpd flags="-DSSL"',
    }

    File['/opt/bin/restart_apache.sh']{
        source => "puppet://$server/apache/OpenBSD/bin/restart_apache_ssl.sh",
    }
    Service['apache']{
        start => 'apachectl startssl',
    }
}
