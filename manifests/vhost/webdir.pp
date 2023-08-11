# manage webdir
define apache::vhost::webdir (
  $ensure               = present,
  $path                 = 'absent',
  $owner                = root,
  $group                = apache,
  $mode                 = '0640',
  $run_mode             = 'normal',
  $manage_docroot       = true,
  $datadir              = true,
  $etcdir               = true,
  $documentroot_owner   = root,
  $documentroot_group   = apache,
  $documentroot_mode    = '0640',
  $documentroot_recurse = false
) {
  $real_path = $path ? {
    'absent' => "/var/www/vhosts/${name}",
    default  => $path,
  }

  $documentroot = "${real_path}/www"
  $logdir = "${real_path}/logs"

  if $owner == 'apache' {
    $real_owner = $facts['os']['name'] ? {
      'Debian' => 'www-data',
      default  => $owner
    }
  } else {
    $real_owner = $owner
  }
  if $group == 'apache' {
    $real_group = $facts['os']['name'] ? {
      'Debian' => 'www-data',
      default  => $group
    }
  } else {
    $real_group = $group
  }

  if $documentroot_owner == 'apache' {
    $real_documentroot_owner = $facts['os']['name'] ? {
      'Debian' => 'www-data',
      default  => $documentroot_owner
    }
  } else {
    $real_documentroot_owner = $documentroot_owner
  }
  if $documentroot_group == 'apache' {
    $real_documentroot_group = $facts['os']['name'] ? {
      'Debian' => 'www-data',
      default  => $documentroot_group
    }
  } else {
    $real_documentroot_group = $documentroot_group
  }
  case $ensure {
    'absent': {
      exec { "cleanup_webdir_${real_path}":
        command => "rm -rf ${real_path}",
        onlyif  => "test -d  ${real_path}",
        require => Service['apache'],
      } -> file { $real_path:
        ensure => absent,
        force  => true,
      }
    }
    default: {
      file {
        default:
          ensure  => directory;
        $real_path:
          require => Anchor['apache::basic_dirs::ready'],
          owner   => $real_owner,
          group   => $real_group,
          mode    => $mode;
        [ "${real_path}/private", "${real_path}/private/bin"]:
          owner => $real_documentroot_owner,
          group => $real_documentroot_group,
          mode  => '0600';
        $logdir:
          before => Service['apache'],
          owner  => $real_documentroot_owner,
          group  => $real_documentroot_group,
          mode   => '0660';
      }
      if $manage_docroot {
        file { $documentroot:
          ensure  => directory,
          before  => Service['apache'],
          recurse => $documentroot_recurse,
          owner   => $real_documentroot_owner,
          group   => $real_documentroot_group,
          mode    => $documentroot_mode;
        }
      }
      if $datadir {
        file { "${real_path}/data":
          ensure => directory,
          owner  => $real_documentroot_owner,
          group  => $real_documentroot_group,
          mode   => '0640';
        }
      }
      if $etcdir {
        file { "${real_path}/etc":
          ensure => directory,
          owner  => root,
          group  => $real_documentroot_group,
          mode   => '0640';
        }
      }
      if str2bool($facts['os']['selinux']['enabled']) {
        if $datadir {
          File["${real_path}/data"] {
            seltype => 'httpd_sys_rw_content_t',
          }
        }
        if $etcdir {
          File["${real_path}/etc"] {
            seltype => 'httpd_sys_rw_content_t',
          }
        }
        if $manage_docroot {
          File[$documentroot] {
            seltype => 'httpd_sys_rw_content_t',
          }
        }
      }
      if $facts['os']['name'] == 'CentOS' {
        include apache::logrotate::centos::vhosts
      }
    }
  }
}
