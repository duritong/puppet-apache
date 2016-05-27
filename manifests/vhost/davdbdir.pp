# a davdb dir
define apache::vhost::davdbdir(
  $ensure             = present,
  $dav_db_dir         = 'absent',
  $documentroot_owner = apache,
  $documentroot_group = 0,
  $documentroot_mode  = '0750',
  $run_mode           = 'normal',
  $run_uid            = 'absent',
){
  # php db dir
  case $dav_db_dir {
    'absent': {
      include apache::defaultdavdbdir
      $real_dav_db_dir = "/var/www/dav_db_dir/${name}"
    }
    default: { $real_dav_db_dir = $dav_db_dir }
  }

  file{$real_dav_db_dir: }
  case $ensure {
    absent: {
      File[$real_dav_db_dir]{
        ensure  => 'absent',
        purge   => true,
        force   => true,
        recurse => true,
      }
    }
    default: {
      File[$real_dav_db_dir]{
        ensure => directory,
        owner  => $documentroot_owner,
        group  => $documentroot_group,
        mode   => $documentroot_mode,
      }
    }
  }
}

