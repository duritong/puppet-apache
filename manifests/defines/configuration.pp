# manifests/defines/configuration.pp

### common configuration defines

# deploy apache (.conf) configuration file (non-vhost)
define apache::config::file(
    $source = '',
    $content = 'absent',
    $destination = ''
){
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
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
    case $content {
        'absent': {
            $real_source = $source ? {
                '' => [ 
                    "puppet://$server/files/apache/conf.d/${fqdn}/${name}",
                    "puppet://$server/files/apache/conf.d/${apache_cluster_node}/${name}",
                    "puppet://$server/files/apache/conf.d/${operatingsystem}.${lsbdistcodename}/${name}",
                    "puppet://$server/files/apache/conf.d/${operatingsystem}/${name}",
                    "puppet://$server/files/apache/conf.d/${name}",
                    "puppet://$server/apache/conf.d/${operatingsystem}.${lsbdistcodename}/${name}",
                    "puppet://$server/apache/conf.d/${operatingsystem}/${name}",
                    "puppet://$server/apache/conf.d/${name}"
                ],
                default => "puppet://$server/$source",
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

# create webdir
define apache::vhost::webdir(
    $path = 'absent',
    $owner = root,
    $group = 0,
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0640,
    $documentroot_recurse = false
){
    $real_path = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/${name}",
            default => "/var/www/vhosts/${name}"
        },
        default => "${path}"
    }

    $documentroot = "${real_path}/www"
    $logdir = "${real_path}/logs"

    case $documentroot_owner {
        apache: {
            case $apache_default_user {
                '': { 
                    $real_documentroot_owner = $operatingsystem ? {
                        openbsd => 'www',
                        default => $documentroot_owner
                    }
                }
                default: { $real_documentroot_owner = $apache_default_user }
            }
        }
        default: { $real_documentroot_owner = $documentroot_owner }
    }
    case $apache_group {
        apache: {
            case $apache_default_group {
                '': {
                    $real_documentroot_group = $operatingsystem ? {
                        openbsd => 'www',
                        default => $documentroot_group
                    }
                }
                default: { $real_documentroot_group = $apache_default_group }
            }
        }
        default: { $real_documentroot_group = $documentroot_group }
    }
    file{"$real_path":
        ensure => directory,
        owner => $owner, group => $group, mode => '0755';
    }
    case $documentroot_recurse {
      '': { $real_documentroot_recurse = false }
      default: { $real_documentroot_recurse = $documentroot_recurse }
    }
    file{"$documentroot":
        ensure => directory,
        owner => $real_documentroot_owner, group => $real_documentroot_group, mode => $documentroot_mode,
        recurse => $real_documentroot_recurse;
    }
    file{$logdir:
        ensure => directory,
        owner => $real_documentroot_owner, group => $group, mode => 750;
    }
}
