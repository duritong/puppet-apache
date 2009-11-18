define apache::vhost::phpdirs(
    $ensure = present,
    $php_bin_dir = 'absent',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0750,
    $run_mode = 'normal',
    $run_uid = 'absent'
){
    # php bin_dir
    case $php_bin_dir {
        'absent': {
            $real_php_bin_dir = "/var/www/vhosts/$name/bin"
        }
        default: { $real_php_upload_tmp_dir = $php_upload_tmp_dir }
    }
    # php upload_tmp_dir
    case $php_upload_tmp_dir {
        'absent': {
            include apache::defaultphpdirs
            $real_php_upload_tmp_dir = "/var/www/upload_tmp_dir/$name"
        }
        default: { $real_php_upload_tmp_dir = $php_upload_tmp_dir }
    }
    # php session_save_path
    case $php_session_save_path {
        'absent': {
            include apache::defaultphpdirs
            $real_php_session_save_path = "/var/www/session.save_path/$name"
        }
        default: { $real_php_session_save_path = $php_session_save_path }
    }

    case $ensure {
        absent: {
            file{[$real_php_upload_tmp_dir, $real_php_session_save_path ]:
                ensure => absent,
                purge => true,
                force => true,
                recurse => true,
            }
        }
        default: {
            file{[$real_php_upload_tmp_dir, $real_php_session_save_path ]:
                ensure => directory,
                owner => $run_mode ? {
                    'itk' => $run_uid,
                    default => $documentroot_owner
                },
                group => $documentroot_group, mode => $documentroot_mode;
            }
        }
    }
}

