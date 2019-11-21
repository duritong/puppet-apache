# some default php dirs
define apache::vhost::phpdirs(
  $path,
  $ensure             = 'present',
  $documentroot_owner = apache,
  $documentroot_group = 0,
  $documentroot_mode  = '0750',
  $run_mode           = 'normal',
  $run_uid            = 'absent',
){
  $owner = $run_mode ? {
    /^(fcgid|fpm)$/ => $run_uid,
    default         => $documentroot_owner,
  }
  file{$path: }
  if $ensure == 'present' {
    if !defined(File["${path}/tmp"]){
      file{"${path}/tmp":
        ensure => directory,
        owner  => $owner,
        group  => $documentroot_group,
        mode   => $documentroot_mode,
      }
    }
    file{["${path}/sessions",
      "${path}/uploads"]: }
    File[$path, "${path}/tmp", "${path}/sessions",
        "${path}/uploads"]{
      ensure => directory,
      owner  => $owner,
      group  => $documentroot_group,
      mode   => $documentroot_mode,
    }
    if str2bool($::selinux) {
      $seltype_rw = $::operatingsystemmajrelease ? {
        '5'     => 'httpd_sys_script_rw_t',
        default => 'httpd_sys_rw_content_t'
      }
      File[$path, "${path}/tmp", "${path}/sessions",
        "${path}/uploads"]{
        seltype => $seltype_rw,
      }
    }
  } else {
    File[$path]{
      ensure  => 'absent',
      force   => true,
      purge   => true,
      recurse => true,
    }
  }
}

