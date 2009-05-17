define apache::centos::module(
    $ensure = present,
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
            "puppet://$server/files/apache/modules.d/${apache_cluster_node}/${name}.so",
            "puppet://$server/files/apache/modules.d/${name}.so",
            "puppet://$server/apache/modules.d/${operatingsystem}/${name}.so",
            "puppet://$server/apache/modules.d/${name}.so"
        ],
        default => "puppet://$server/$source",
    }
    file{"modules_${name}.conf":
        ensure => $ensure,
        path => $real_destination,
        source => $real_source,
        require => [ File[modules_dir], Package[apache] ],
        notify => Service[apache],
        owner => root, group => 0, mode => 0755;
    }
}

