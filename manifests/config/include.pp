# deploy apache configuration file (includes for vhosts)
define apache::config::include(
    $ensure = present,
    $source = 'absent',
    $content = 'absent',
    $destination = 'absent'
){
    $real_destination = $destination ? {
        'absent' => $operatingsystem ? {
            centos => "${apache::centos::config_dir}/include.d/${name}",
            gentoo => "${apache::gentoo::config_dir}/${name}",
            debian => "${apache::debian::config_dir}/include.d/${name}",
            ubuntu => "${apache::ubuntu::config_dir}/include.d/${name}",
            openbsd => "${apache::openbsd::config_dir}/include.d/${name}",
            default => "/etc/apache2/${name}",
        },
        default => $destination
    }
    if ($content == 'absent') {
        $real_source = $source ? {
            'absent' => [
                "puppet://${server}/modules/site-apache/include.d/${fqdn}/${name}",
                "puppet://${server}/modules/site-apache/include.d/${apache_cluster_node}/${name}",
                "puppet://${server}/modules/site-apache/include.d/${operatingsystem}.${lsbdistcodename}/${name}",
                "puppet://${server}/modules/site-apache/include.d/${operatingsystem}/${name}",
                "puppet://${server}/modules/site-apache/include.d/${name}",
                "puppet://${server}/modules/apache/include.d/${operatingsystem}.${lsbdistcodename}/${name}",
                "puppet://${server}/modules/apache/include.d/${operatingsystem}/${name}",
                "puppet://${server}/modules/apache/include.d/${name}"
            ],
            default => "puppet://${server}/${source}",
        }
    }
    apache::config::file { "${name}":
        ensure => $ensure,
        source => $real_source,
        content => $content,
        destination => $real_destination,
    }
}
