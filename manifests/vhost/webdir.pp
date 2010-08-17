# create webdir
define apache::vhost::webdir(
    $ensure = present,
    $path = 'absent',
    $owner = root,
    $group = apache,
    $mode = 0640,
    $run_mode = 'normal',
    $manage_docroot = true,
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

    if ($run_mode =~ /^(static\-|proxy\-)?itk$/) and ($mode == '0640'){
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
          debian => 'www-data',
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
          debian => 'www-data',
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
          debian => 'www-data',
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
          debian => 'www-data',
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
            if $manage_docroot {
              $managed_directories = [ "$real_path", "${real_path}/private", "$logdir", "$documentroot" ]
            } else {
              $managed_directories = [ "$real_path", "${real_path}/private", "$logdir" ]
            }
            file{$managed_directories:
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
            if $manage_docroot {
              file{"$documentroot":
                ensure => directory,
                recurse => $documentroot_recurse,
                owner => $real_documentroot_owner, group => $real_documentroot_group, mode => $documentroot_mode;
              }
            }
            file{"$logdir":
                ensure => directory,
                owner => $real_documentroot_owner, group => $real_documentroot_group, mode => 0660;
            }
            case $operatingsystem {
                centos: { include apache::logrotate::centos::vhosts }
            }
            file{"${real_path}/private":
                ensure => directory,
                owner => $real_documentroot_owner, group => $real_documentroot_group, mode => 0600;
            }
        }
    }
}

