# manifests/defines.pp

define apache::config::file(
    $source = '',
    $destination = ''
){
    $real_source = $source ? {
        # get a whole bunch of possible sources if there is no specific source for that config-file
        '' => [ 
            "puppet://$server/files/apache/conf.d/${fqdn}/${name}",
            "puppet://$server/files/apache/conf.d/${name}",
            "puppet://$server/apache/conf.d/${operatingsystem}.${lsbdistcodename}/${name}",
            "puppet://$server/apache/conf.d/${operatingsystem}/${name}",
            "puppet://$server/apache/conf.d/${name}"
        ],
        default => "puppet://$server/$source",
    }
    $real_destination = $destination ? {
        '' => $operatingsystem ? {
            centos => "$apache::centos::config_dir/conf.d/${name}",
            gentoo => "$apache::gentoo::config_dir/${name}",
            debian => "$apache::debian::config_dir/conf.d/${name}",
            ubuntu => "$apache::ubuntu::config_dir/conf.d/${name}",
            openbsd => "$apache::openbsd::config_dir/conf.d/${name}",
            default => "/etc/apache2/${name}",
        },
        default => $destination
    }
    file{"apache_${name}":
        path => $real_destination,
        source => $real_source,
        require => Package[apache],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
}

define apache::vhost::file(
    $source = 'absent',
    $destination = 'absent',
    $content = 'absent'
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
        'absent' => "${vhosts_dir}/${name}.conf",
        default => $destination,
    } 
    file{"${name}.conf":
        path => $real_destination,
        require => [ File[vhosts_dir], Package[apache] ],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
    case $content {
        'absent': {
            $real_source = $source ? {
                'absent'  => [ 
                    "puppet://$server/files/apache/vhosts.d/${fqdn}/${name}.conf",
                    "puppet://$server/files/apache/vhosts.d/${name}.conf", 
                    "puppet://$server/apache/vhosts.d/${name}.conf",
                    "puppet://$server/apache/vhosts.d/${operatingsystem}.${lsbdistcodename}/${name}.conf",
                    "puppet://$server/apache/vhosts.d/${operatingsystem}/${name}.conf",
                    "puppet://$server/apache/vhosts.d/${name}.conf"
                ],
                default => "puppet://$server/$source",
            }
            File["${name}.conf"]{
                source => $real_source,
            }
        }
        default: {
            File["${name}.conf"]{
                content => $content,
            }
        }
    }
}

define apache::centos::module(
    $source = '',
    $destination = ''
){
    $modules_dir = "$apache::centos::config_dir/modules.d/"
    $real_destination = $destination ? {
        '' => "${modules_dir}/${name}.so",
        default => $destination,
    }
    $real_source = $source ? {
        ''  => [
            "puppet://$server/files/apache/modules.d/${fqdn}/${name}.so",
            "puppet://$server/files/apache/modules.d/${name}.so",
            "puppet://$server/apache/modules.d/${operatingsystem}/${name}.so",
            "puppet://$server/apache/modules.d/${name}.so"
        ],
        default => "puppet://$server/$source",
    }
    file{"modules_${name}.conf":
        path => $real_destination,
        source => $real_source,
        require => [ File[modules_dir], Package[apache] ],
        notify => Service[apache],
        owner => root, group => 0, mode => 0755;
    }
}


define apache::gentoo::module(
    $source = '',
    $destination = ''
){
    $modules_dir = "$apache::gentoo::config_dir/modules.d/"
    $real_destination = $destination ? {
        '' => "${modules_dir}/${name}.conf",
        default => $destination,
    } 
    $real_source = $source ? {
        ''  => [ 
            "puppet://$server/files/apache/modules.d/${fqdn}/${name}.conf",
            "puppet://$server/files/apache/modules.d/${name}.conf", 
            "puppet://$server/apache/modules.d/${operatingsystem}/${name}.conf",
            "puppet://$server/apache/modules.d/${name}.conf" 
        ],
        default => "puppet://$server/$source",
    }
    file{"modules_${name}.conf":
        path => $real_destination,
        source => $real_source,
        require => [ File[modules_dir], Package[apache] ],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
}
