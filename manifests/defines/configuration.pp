# manifests/defines/configuration.pp

### common configuration defines

# deploy apache (.conf) configuration file (non-vhost)
define apache::config::file(
    $ensure = present,
    $source = 'absent',
    $content = 'absent',
    $destination = 'absent'
){
    $real_destination = $destination ? {
        'absent' => $operatingsystem ? {
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
        ensure => $ensure,
        path => $real_destination,
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
    case $content {
        'absent': {
            $real_source = $source ? {
                'absent' => [ 
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
    $ensure = present,
    $path = 'absent',
    $owner = root,
    $group = apache,
    $mode = 0640,
    $run_mode = 'normal',
    $documentroot_owner = root,
    $documentroot_group = apache,
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

    if ($run_mode == 'itk') and ($mode == '0640'){
      $real_mode = 0644
    } else {
      $real_mode = $mode
    }

    $documentroot = "${real_path}/www"
    $logdir = "${real_path}/logs"

    if $owner == 'apache' {
      if $apache_default_user == '' {
        $real_owner = $operatingsystem ? {
          openbsd => 'www',
          default => $owner
        }
      } else {
        $real_owner = $apache_default_user
      }
    } else {
        $real_owner = $owner
    }
    if $group == 'apache' {
      if $apache_default_group == '' {
        $real_group = $operatingsystem ? {
          openbsd => 'www',
          default => $group
        }
      } else {
        $real_group = $apache_default_group
      }
    } else {
      $real_group = $group
    }

    if $documentroot_owner == 'apache' {
      if $apache_default_user == '' {
        $real_documentroot_owner = $operatingsystem ? {
          openbsd => 'www',
          default => $documentroot_owner
        }
      } else {
        $real_documentroot_owner = $apache_default_user
      }
    } else {
        $real_documentroot_owner = $documentroot_owner
    }
    if $documentroot_group == 'apache' {
      if $apache_default_group == '' {
        $real_documentroot_group = $operatingsystem ? {
          openbsd => 'www',
          default => $documentroot_group
        }
      } else {
        $real_documentroot_group = $apache_default_group
      }
    } else {
      $real_documentroot_group = $documentroot_group
    }
    case $ensure {
        absent: {
            file{[ "$real_path", "$documentroot", "$logdir" ]:
                ensure => absent,
                purge => true,
                recurse => true,
                force => true,
            }
        }
        default: {
            file{"$real_path":
                ensure => directory,
                owner => $real_owner, group => $real_group, mode => $real_mode;
            }
            file{"$documentroot":
                ensure => directory,
                recurse => $documentroot_recurse,
                owner => $real_documentroot_owner, group => $real_documentroot_group, mode => $documentroot_mode;
            }
            file{"$logdir":
                ensure => directory,
                owner => $real_documentroot_owner, group => $real_documentroot_group, mode => 770;
            }
        }
    }
}
