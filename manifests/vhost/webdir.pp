# manage webdir
define apache::vhost::webdir(
  $ensure               = present,
  $path                 = 'absent',
  $owner                = root,
  $group                = apache,
  $mode                 = '0640',
  $run_mode             = 'normal',
  $manage_docroot       = true,
  $datadir              = true,
  $documentroot_owner   = root,
  $documentroot_group   = apache,
  $documentroot_mode    = '0640',
  $documentroot_recurse = false
){
  $real_path = $path ? {
    'absent' => "/var/www/vhosts/${name}",
    default  => $path,
  }

  $documentroot = "${real_path}/www"
  $logdir = "${real_path}/logs"

  if $owner == 'apache' {
    $real_owner = $::operatingsystem ? {
      'Debian' => 'www-data',
      default  => $owner
    }
  } else {
      $real_owner = $owner
  }
  if $group == 'apache' {
    $real_group = $::operatingsystem ? {
      'Debian' => 'www-data',
      default  => $group
    }
  } else {
    $real_group = $group
  }

  if $documentroot_owner == 'apache' {
    $real_documentroot_owner = $::operatingsystem ? {
      'Debian' => 'www-data',
      default  => $documentroot_owner
    }
  } else {
    $real_documentroot_owner = $documentroot_owner
  }
  if $documentroot_group == 'apache' {
    $real_documentroot_group = $::operatingsystem ? {
      'Debian' => 'www-data',
      default  => $documentroot_group
    }
  } else {
    $real_documentroot_group = $documentroot_group
  }
  case $ensure {
    absent: {
      exec{"cleanup_webdir_${real_path}":
        command => "rm -rf ${real_path}",
        onlyif  => "test -d  ${real_path}",
        require => Service['apache'],
      } -> file{$real_path:
        ensure => absent,
        force  => true,
      }
    }
    default: {
      file{
        $real_path:
          ensure  => directory,
          require => Anchor['apache::basic_dirs::ready'],
          owner   => $real_owner,
          group   => $real_group,
          mode    => $mode;
        $logdir:
          ensure => directory,
          before => Service['apache'],
          owner  => $real_documentroot_owner,
          group  => $real_documentroot_group,
          mode   => '0660';
        "${real_path}/private":
          ensure => directory,
          owner  => $real_documentroot_owner,
          group  => $real_documentroot_group,
          mode   => '0600';
      }
      if $manage_docroot {
        file{$documentroot:
          ensure  => directory,
          before  => Service['apache'],
          recurse => $documentroot_recurse,
          owner   => $real_documentroot_owner,
          group   => $real_documentroot_group,
          mode    => $documentroot_mode;
        }
      }
      if $datadir {
        file{"${real_path}/data":
          ensure => directory,
          owner  => $real_documentroot_owner,
          group  => $real_documentroot_group,
          mode   => '0640';
        }
      }
      if str2bool($::selinux) {
        $seltype_rw = $::operatingsystemmajrelease ? {
          '5'     => 'httpd_sys_script_rw_t',
          default => 'httpd_sys_rw_content_t'
        }
        if $datadir {
          File["${real_path}/data"]{
            seltype => $seltype_rw,
          }
        }
        if $manage_docroot {
          File[$documentroot]{
            seltype => $seltype_rw,
          }
        }
      }
      if $::operatingsystem == 'CentOS' {
        include ::apache::logrotate::centos::vhosts
      }
    }
  }
}

