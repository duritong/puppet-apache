# deploy apache configuration file
# by default we assume it's a global configuration file
define apache::config::file(
    $ensure = present,
    $source = 'absent',
    $content = 'absent',
    $destination = 'absent'
){
    $real_destination = $destination ? {
        'absent' => $operatingsystem ? {
            centos => "${apache::centos::config_dir}/conf.d/${name}",
            gentoo => "${apache::gentoo::config_dir}/${name}",
            debian => "${apache::debian::config_dir}/conf.d/${name}",
            ubuntu => "${apache::ubuntu::config_dir}/conf.d/${name}",
            openbsd => "${apache::openbsd::config_dir}/conf.d/${name}",
            default => "/etc/apache2/${name}",
        },
        default => $destination
    }
    file{"apache_${name}":
        ensure => $ensure,
        path => $real_destination,
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
    case $content {
        'absent': {
            $real_source = $source ? {
                'absent' => [
                    "puppet://${server}/modules/site-apache/conf.d/${fqdn}/${name}",
                    "puppet://${server}/modules/site-apache/conf.d/${apache_cluster_node}/${name}",
                    "puppet://${server}/modules/site-apache/conf.d/${operatingsystem}.${lsbdistcodename}/${name}",
                    "puppet://${server}/modules/site-apache/conf.d/${operatingsystem}/${name}",
                    "puppet://${server}/modules/site-apache/conf.d/${name}",
                    "puppet://${server}/modules/apache/conf.d/${operatingsystem}.${lsbdistcodename}/${name}",
                    "puppet://${server}/modules/apache/conf.d/${operatingsystem}/${name}",
                    "puppet://${server}/modules/apache/conf.d/${name}"
                ],
                default => "puppet://${server}/${source}",
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
    case $operatingsystem {
        openbsd: { info("no package dependency on ${operatingsystem} for ${name}") }
        default: {
            File["apache_${name}"]{
                require => Package[apache],
            }
        }
    }
}
