# modules/apache/manifests/init.pp
# 2008 - admin(at)immerda.ch
# License: GPLv3


class apache {
    package { 'apache':
        name => $operatingsystem ? {
            centos => 'httpd',
            default => 'apache'
        },
        category => $operatingsystem ? {
            gentoo => 'www-servers',
            default => '',
        },
            ensure => present,
        }

    case $operatingsystem {
        centos: {
            package { 'mod_ssl':
                name => 'mod_ssl',
                    ensure => present,
            }
        }
    }

    service { apache:
        name => $operatingsystem ? {
            centos => 'httpd',
            default => 'apache2'
        },
        enable => true,
        ensure => running,
        require => Package[apache],
    }

    file { 'default_index':
        path => $operatingsystem ? {
            centos => '/var/www/html/index.html',
            default => '/var/www/localhost/index.html'
        },
        ensure => file,
        owner => 'root',
        group => 0,
        mode => 644,
        require => Package[apache],
        content => template('apache/default/default_index.erb'),
    }

    case $operatingsystem {
        centos:  { include apache_centos }
    }
}



### distro specific stuff
class apache_centos {
        file {'/etc/httpd/vhosts.d':
                ensure => directory,
                owner => root,
                group => 0,
                mode => 700,
        }
}

