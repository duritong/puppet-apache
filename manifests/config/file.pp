# deploy apache configuration file
# by default we assume it's a global configuration file
define apache::config::file(
    $ensure = present,
    $type = 'global',
    $source = 'absent',
    $content = 'absent',
    $destination = 'absent'
){
    case $type {
        'include': { $confdir = 'include.d' }
        'global': { $confdir = 'conf.d' }
        default: { fail("Wrong config file type specified for ${name}") }
    }
    $real_destination = $destination ? {
        'absent' => $operatingsystem ? {
            centos => "${apache::centos::config_dir}/${confdir}/${name}",
            gentoo => "${apache::gentoo::config_dir}/${name}",
            debian => "${apache::debian::config_dir}/${confdir}/${name}",
            ubuntu => "${apache::ubuntu::config_dir}/${confdir}/${name}",
            openbsd => "${apache::openbsd::config_dir}/${confdir}/${name}",
            default => "/etc/apache2/${confdir}/${name}",
        },
        default => $destination
    }
    file{"apache_${name}":
        ensure => $ensure,
        path => $real_destination,
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
    if $ensure == 'present' {
      case $content {
        'absent': {
            $real_source = $source ? {
                'absent' => [
                    "puppet:///modules/site_apache/${confdir}/${::fqdn}/${name}",
                    "puppet:///modules/site_apache/${confdir}/${apache::cluster_node}/${name}",
                    "puppet:///modules/site_apache/${confdir}/${::operatingsystem}.${::lsbdistcodename}/${name}",
                    "puppet:///modules/site_apache/${confdir}/${::operatingsystem}/${name}",
                    "puppet:///modules/site_apache/${confdir}/${name}",
                    "puppet:///modules/apache/${confdir}/${::operatingsystem}.${::lsbdistcodename}/${name}",
                    "puppet:///modules/apache/${confdir}/${::operatingsystem}/${name}",
                    "puppet:///modules/apache/${confdir}/${name}"
                ],
                default => "puppet:///${source}",
            }
            File["apache_${name}"]{
                source => $real_source,
            }
        }
        default: {
            File["apache_${name}"]{
                content => $content,
            }
        }
      }
    }
    case $::operatingsystem {
        openbsd: { info("no package dependency on ${::operatingsystem} for ${name}") }
        default: {
            File["apache_${name}"]{
                require => Package[apache],
            }
        }
    }
}
