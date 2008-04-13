# modules/apache/manifests/init.pp
# 2008 - admin(at)immerda.ch
# License: GPLv3

import "modules/*.pp"

class apache {
    case $operatingsystem {
        centos: { include apache::centos }
        gentoo: { include apache::gentoo }
        debian: { include apache::debian }
        ubuntu: { include apache::ubuntu }
        default: { include apache::base }
    }
}

class apache::base {

    file{'vhosts_dir':
        path => '/etc/apache2/vhosts.d/',
        ensure => directory,
        owner => root,
        group => 0,
        mode => 0755,
        require => Package[apache],
    }

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
        path => '/var/www/localhost/htdocs/index.html',
        ensure => file,
        owner => 'root',
        group => 0,
        mode => 644,
        require => Package[apache],
        content => template('apache/default/default_index.erb'),
    }
    include munin::plugins::apache
}

### distro specific stuff
class apache::centos inherits apache::base{
    $config_dir = '/etc/httpd/'
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
    File[vhosts_dir]{
        path => "$config_dir/vhosts.d/",
    }

    file{"${config_dir}/conf.d/ZZZ_vhosts.conf":
        source => "puppet://$servername/apache/centos/vhosts.conf",
        owner => root, group => 0, mode => 0755;
    }
    file{"${config_dir}/conf.d/ssl.conf":
        source => "puppet://$servername/apache/centos/ssl.conf",
        owner => root, group => 0, mode => 0755;
    }
    apache::vhost::file { '00_default_centos_vhost': }
}

class apache::gentoo inherits apache::base {
    $config_dir = '/etc/apache2/'

    # needs module gentoo
    gentoo::etcconfd { apache2: require => "Package[apache]", notify => "Service[apache]"} 

    Package[apache]{
        category => 'www-servers',
    } 
    File[vhosts_dir]{
        path => "$config_dir/vhosts.d/",
    }
    apache::vhost::file { '00_default_ssl_vhost': }
    apache::vhost::file { '00_default_vhost': }
    apache::config::file { 'default_vhost.include': 
        source => "apache/vhosts.d/default_vhost.include",
        destination => "$config_dir/vhosts.d/default_vhost.include",
    }
}

class apache::debian inherits apache::base {
    $config_dir = '/etc/apache2/'
    file {"vhosts_dir":
        ensure => '/etc/apache2/sites-enabled/',
    }
    File[default_apache_index] {
        path => '/var/www/index.html',
    }
}
# ubuntu is similar to debian therefor inheritng from there
class apache::ubuntu inherits apache::debian {}
class apache::openbsd inherits apache::base {
    $config_dir = '/var/www/conf/'
    File[vhosts_dir]{
        path => "$config_dir/vhosts.d/",
    }
    File[default_apache_index] {
        path => '/var/www/htdocs/index.html',
    }
}


### config things
define apache::vhost::file(
    $source = '',
    $destination = ''
){
    $vhosts_dir = $operatingsystem ? {
            centos => "$apache::centos::config_dir/vhosts.d/",
            gentoo => "$apache::gentoo::config_dir/vhosts.d/",
            debian => "$apache::debian::config_dir/vhosts.d/",
            ubuntu => "$apache::ubuntu::config_dir/vhosts.d/",
            openbsd => "$apache::openbsd::config_dir/vhosts.d/",
            default => '/etc/apache2/vhosts.d/',
    }

    $real_destination = $destination ? {
        '' => "${vhosts_dir}/${name}.conf",
        default => $destination,
    } 

    $real_source = $source ? {
        ''  => [ 
            "puppet://$server/files/apache/vhosts.d/${fqdn}/${name}.conf",
            "puppet://$server/files/apache/vhosts.d/${name}.conf", 
            "puppet://$server/apache/vhosts.d/${name}.conf" 
        ],
        default => "puppet://$server/$source",
    }

    file{"vhost_${name}.conf":
        path => $real_destination,
        source => $real_source,
        owner => root,
        group => 0,
        mode => 0644, 
        require => [ File[$vhosts_dir], Package[apache] ],
        notify => Service[apache],
    }
}

define apache::config::file(
    $source = '',
    $destination = ''
){
    $real_source = $source ? {
        # get a whole bunch of possible sources if there is no specific source for that config-file
        '' => [ 
            "puppet://$server/files/apache/conf/${fqdn}/${name}",
            "puppet://$server/files/apache/conf/${name}",
            "puppet://$server/apache/conf/${name}.${operatingsystem}.${lsbdistcodename}",
            "puppet://$server/apache/conf/${name}.${operatingsystem}",
            "puppet://$server/apache/conf/${name}.Default",
            "puppet://$server/apache/conf/${name}"
        ],
        default => "puppet://$server/$source",
    }

    $real_destination = $destination ? {
        '' => $operatingsystem ? {
            centos => "$apache::centos::config_dir/${name}",
            gentoo => "$apache::gentoo::config_dir/${name}",
            debian => "$apache::debian::config_dir/${name}",
            ubuntu => "$apache::ubuntu::config_dir/${name}",
            openbsd => "$apache::openbsd::config_dir/${name}",
            default => "/etc/apache2/${name}",
        },
        default => $destination
    }

    file{"apache_${name}":
        path => $real_destination,
        source => $real_source,
        owner => root,
        group => 0,
        mode => 0644,
        require => Package[apache],
        notify => Service[apache],
    }
}

#php
class apache::php inherits apache {
    case $operatingsystem {
        debian: { include php::debian }
        centos: { include php::centos }
        ubuntu: { include php::ubuntu }
        gentoo: { include php::gentoo }
        default: { include php::base }
    }
}

class apache::status {
    case $operatingsystem {
        centos: { include apache::status::centos }
    }
}

class apache::status::centos {
    file{"/etc/httpd/conf.d/status.conf":
        source => "puppet://$servername/apache/centos/status.conf",
        owner => root, group => 0, mode => 644;
    }
}
