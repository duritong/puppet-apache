#
# apache module
#
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

import "defines.pp"

class apache {
    case $operatingsystem {
        centos: { include apache::centos }
        gentoo: { include apache::gentoo }
        debian: { include apache::debian }
        ubuntu: { include apache::ubuntu }
        default: { include apache::base }
    }
    if $selinux {
        include apache::selinux
    }
    if $use_munin {
        include apache::status
    }
}

class apache::base {
    file{'vhosts_dir':
        path => '/etc/apache2/vhosts.d/',
        ensure => directory,
        owner => root, group => 0, mode => 0755;
    }
    file{'modules_dir':
        path => '/etc/apache2/modules.d/',
        ensure => directory,
        owner => root, group => 0, mode => 0755;
    }
    service { apache:
        name => 'apache2',
        enable => true,
        ensure => running,
    }
    file { 'default_apache_index':
        path => '/var/www/localhost/htdocs/index.html',
        ensure => file,
        content => template('apache/default/default_index.erb'),
        owner => root, group => 0, mode => 0644;
    }
}

class apache::package inherits apache::base {
    package { 'apache':
        name => 'apache',
        ensure => present,
    }
    File['vhosts_dir']{
        require => Package[apache],
    }
    Service['apache']{
        require => Package[apache],
    }
    File['default_apache_index']{
        require => Package[apache],
    }
    File['modules_dir']{
        require => Package[apache],
    }
}


### distribution specific classes

### centos
class apache::centos inherits apache::package {
    $config_dir = '/etc/httpd/'

    Package[apache]{
        name => 'httpd',
    } 
    Service[apache]{
        name => 'httpd',
    }
    File[vhosts_dir]{
        path => "$config_dir/vhosts.d/",
    }
    File[modules_dir]{
        path => "$config_dir/modules.d/",
    }
    File[default_apache_index]{
        path => '/var/www/html/index.html',
    }
    apache::config::file{ 'welcome.conf': }
    apache::config::file{ 'defaults.inc': }
    apache::config::file{ 'vhosts.conf': }
    apache::vhost::file { '0-default': }
}

### gentoo
class apache::gentoo inherits apache::package {
    $config_dir = '/etc/apache2/'

    # needs module gentoo
    gentoo::etcconfd {
        apache2: require => "Package[apache]", 
        notify => "Service[apache]"
    } 
    Package[apache]{
        category => 'www-servers',
    } 
    File[vhosts_dir]{
        path => "$config_dir/vhosts.d/",
    }
    File[modules_dir]{
        path => "$config_dir/modules.d/",
    }
    apache::gentoo::module { '00_default_settings': }
    apache::gentoo::module { '00_error_documents': }

    apache::vhost::file { '00_default_vhost': }
    apache::config::file { 'default_vhost.include': 
        source => "apache/vhosts.d/default_vhost.include",
        destination => "$config_dir/vhosts.d/default_vhost.include",
    }
    
    # set the default for the ServerName
    file{"${config_dir}/modules.d/00_default_settings_ServerName.conf":
        content => template('apache/modules_dir_00_default_settings_ServerName.conf.erb'),
        require => Package[apache],
        owner => root, group => 0, mode => 0644;
    }
}

### debian
class apache::debian inherits apache::package {
    $config_dir = '/etc/apache2/'

    file {"$vhosts_dir":
        ensure => '/etc/apache2/sites-enabled/',
    }
    File[default_apache_index] {
        path => '/var/www/index.html',
    }

}

### ubuntu: similar to debian therefor inheritng from there
class apache::ubuntu inherits apache::debian {}

### openbsd
class apache::openbsd inherits apache::base {
    $config_dir = '/var/www/conf/'

    File[vhosts_dir]{
        path => "$config_dir/vhosts.d/",
    }
    File[modules_dir]{
        path => "$config_dir/modules.d/",
    }
    File[default_apache_index] {
        path => '/var/www/htdocs/index.html',
    }
}
