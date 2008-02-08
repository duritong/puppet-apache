# modules/apache/manifests/init.pp
# 2008 - admin(at)immerda.ch
# License: GPLv3

class apache {
    package { 'apache':
        name => 'apache',
        ensure => present,
    }

    service { apache:
        name => 'apache2',
        enable => true,
        ensure => running,
        require => Package[apache],
    }

    file { 'default_apache_index':
        path => '/var/www/localhost/index.html',
        ensure => file,
        owner => 'root',
        group => 0,
        mode => 644,
        require => Package[apache],
        content => template('apache/default/default_index.erb'),
    }

    case $operatingsystem {
        centos: { include apache::centos }
        gentoo: { include apache::gentoo }
    }
}



### distro specific stuff
class apache::centos {
    Package[apache]{
        name => 'httpd',
    } 
    Service[apache]{
        name => 'httpd'
    }
    package { 'mod_ssl':
        name => 'mod_ssl',
        ensure => present,
        require => Package[apache],
    }

    File[default_apache_index]{
        path => '/var/www/html/index.html',
    }

    file {'/etc/httpd/vhosts.d':
        ensure => directory,
        owner => root,
        group => 0,
        mode => 750,
    }
}

class apache::gentoo {
    Package[apache]{
        category => 'www-servers',
    } 
}
