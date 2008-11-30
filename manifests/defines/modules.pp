# manifests/defines/modules.pp

### manage apache modules

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
            "puppet://$server/files/apache/modules.d/${apache_cluster_node}/${name}.so",
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
            "puppet://$server/files/apache/modules.d/${apache_cluster_node}/${name}.conf",
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
