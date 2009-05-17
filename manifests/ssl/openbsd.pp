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
