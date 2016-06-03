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
  file{[$php_upload_tmp_dir, $php_session_save_path]: }
  case $ensure {
    'absent': {
      File[$php_upload_tmp_dir, $php_session_save_path]{
        ensure  => absent,
        purge   => true,
        force   => true,
        recurse => true,
      }
    }
    default: {
      include ::apache::defaultphpdirs
      $owner = $run_mode ? {
        'fcgid' => $run_uid,
        default => $documentroot_owner
      }
      File[$php_upload_tmp_dir, $php_session_save_path]{
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
        File[$php_upload_tmp_dir, $php_session_save_path]{
          seltype => $seltype_rw,
        }
      }
    }
  }
}

