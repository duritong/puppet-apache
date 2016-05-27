# some default php dirs
define apache::vhost::phpdirs(
  $php_upload_tmp_dir,
  $php_session_save_path,
  $ensure             = present,
  $documentroot_owner = apache,
  $documentroot_group = 0,
  $documentroot_mode  = '0750',
  $run_mode           = 'normal',
  $run_uid            = 'absent',
){
  case $ensure {
    'absent': {
      file {
        [$php_upload_tmp_dir, $php_session_save_path]:
          ensure  => absent,
          purge   => true,
          force   => true,
          recurse => true,
      }
    }
    default: {
      include apache::defaultphpdirs
      $owner = $run_mode ? {
        'fcgid' => $run_uid,
        default => $documentroot_owner
      }
      file {
        [$php_upload_tmp_dir, $php_session_save_path]:
          ensure => directory,
          owner  => $owner,
          group  => $documentroot_group,
          mode   => $documentroot_mode;
      }
    }
  }
}

