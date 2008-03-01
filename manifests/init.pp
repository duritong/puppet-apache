# modules/apache/manifests/init.pp
# 2008 - admin(at)immerda.ch
# License: GPLv3

class apache {
    case $operatingsystem {
        centos: { include apache::centos }
        gentoo: { include apache::gentoo }
        debian: { include apache::debian }
        ubuntu: { include apache::ubuntu }
        default: { include apache::base }
    }

    #include apache::gentoo

#    $vhosts_dir = $operatingsystem ? {
#            centos => "$apache::centos::config_dir/vhosts.d/",
#            gentoo => "$apache::gentoo::config_dir/vhosts.d/",
#            debian => "$apache::debian::config_dir/vhosts.d/",
#            ubuntu => "$apache::ubuntu::config_dir/vhosts.d/",
#            openbsd => "$apache::openbsd::config_dir/vhosts.d/",
#            default => '/etc/apache2/vhosts.d/',
#    }
    
    $vhosts_dir = "$config_dir/vhosts.d/"

notice("vhosts_dir=${vhosts_dir}")

    file{
        $vhosts_dir:
        ensure => directory,
        owner => root,
        group => 0,
        mode => 0755,
        require => Package[apache],
    }
}

class apache::base {
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
}



### distro specific stuff
class apache::centos inherits apache::base{
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
    $config_dir = '/etc/httpd/'
}

class apache::gentoo inherits apache::base {
    # $config_dir = '/etc/apache2/'
    Package[apache]{
        category => 'www-servers',
    } 
    # needs module gentoo
    gentoo::etcconfd { apache2: } 
}

class apache::debian inherits apache::base {
    $config_dir = '/etc/apache2/'
    file {"${config_dir}/vhosts.d/":
        ensure => '/etc/apache2/sites-enabled/',
    }
}
# ubuntu is similar to debian therefor inheritng from there
class apache::ubuntu inherits apache::debian {}
class apache::openbsd inherits apache::base {
    $config_dir = '/var/www/conf/'
}


### config things
define apache::vhost::file(
    $source = '',
    $destination = ''
){
    $vhosts_dir = "$config_dir/vhosts.d/"
notice("vhosts_dir_vhost::file=${vhosts_dir}")
#    $vhosts_dir = $operatingsystem ? {
#            centos => "$apache::centos::config_dir/vhosts.d/",
#            gentoo => "$apache::gentoo::config_dir/vhosts.d/",
#            debian => "$apache::debian::config_dir/vhosts.d/",
#            ubuntu => "$apache::ubuntu::config_dir/vhosts.d/",
#            openbsd => "$apache::openbsd::config_dir/vhosts.d/",
#            default => '/etc/apache2/vhosts.d/',
#    }
#
#    file{
#        $vhosts_dir:
#        ensure => directory,
#        owner => root,
#        group => 0,
#        mode => 0755,
#        require => Package[apache],
#    }
 
    $real_destination = $destination ? {
        '' => "${vhosts_dir}/${name}.conf",
        default => $destination,
    } 

    $real_source = $source ? {
        ''  => [ 
            "apache/vhosts.d/${fqdn}/${name}.conf", 
            "dist/apache/vhosts.d/${fqdn}/${name}.conf" 
        ],
        default => $source,
    }

    file{"vhost_${name}.conf":
        path => $real_destination,
        source => "puppet://$server/$real_source",
        owner => root,
        group => 0,
        mode => 0644, 
        require => File[$vhosts_dir], 
        require => Package[apache],
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
            "apache/conf/${fqdn}/${name}", 
            "dist/apache/conf/${fqdn}/${name}",
            "apache/conf/${name}.${operatingsystem}.${lsbdistcodename}",
            "apache/conf/${name}.${operatingsystem}",
            "apache/conf/${name}.Default"
        ],
        default => $source,
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
        source => "puppet://$server/$real_source",
        owner => root,
        group => 0,
        mode => 0644,
        require => Class[apache],
        notify => Service[apache],
    }
}
