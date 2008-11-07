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

define apache::vhost::php::standard(
    $domain = 'absent',
    $domainalias = 'absent',
    $path = 'absent',
    $owner = root,
    $group = 0,
    $mode = 0644,
    $apache_user = apache,
    $apache_group = 0,
    $apache_mode = 0640,
    $allow_override = 'None',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $additional_options = 'absent',
    $mod_security = 'true'
){
    $servername = $domain ? {
        'absent' => $name,
        default => $domain
    }
    $serveralias = $domainalias ? {
        'absent' => '',
        default => $domainalias
    }
    $real_path = $path ? {
        'absent' => "/var/www/${name}",
        default => "${path}"
    }
    $documentroot = "${real_path}/www"
    $logdir = "${real_path}/logs"

    file{ [ "$real_path", "$documentroot", "$logdir" ] :
        ensure => directory,
        owner => $owner, group => $group, mode => $mode;
    }

    case $php_upload_tmp_dir {
        'absent': {
            include apache::defaultphpdirs
            $upload_tmp_dir = "/var/www/upload_tmp_dir/${name}"
        }
        default: {
            $upload_tmp_dir = $php_upload_tmp_dir
        }
    }
    file{"$upload_tmp_dir":
        ensure => directory,
        owner => $apache_user, group => $apache_group, mode => $apache_mode;
    }

    case $php_session_save_path {
        'absent': {
            include apache::defaultphpdirs
            $session_save_path = "/var/www/session.save_path/${name}"
        }
        default: {
            $session_save_path = $php_session_save_path
        }
    }
    file{"$session_save_path":
        ensure => directory,
        owner => $apache_user, group => $apache_group, mode => $apache_mode;
    }


    file{"/etc/httpd/vhosts.d/${servername}.conf":
        content => template("apache/vhosts/php/${operatingsystem}.erb"),
        notify => Service['apache'],
        owner => root, group => 0, mode => 0644;
    }
}

