# run_mode:
#   - normal: nothing special (*default*)
#   - itk: apache is running with the itk module
#          and run_uid and run_gid are used as vhost users
# run_uid: the uid the vhost should run as with the itk module
# run_gid: the gid the vhost should run as with the itk module
# php_safe_mode_exec_bins: An array of local binaries which should be linked in the
#                          safe_mode_exec_bin for this hosting
#                          *default*: None
# php_default_charset: default charset header for php.
#                      *default*: absent, which will set the same as default_charset
#                                 of apache
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
define apache::vhost::php::gallery2(
    $ensure = present,
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $logmode = 'default',
    $path = 'absent',
    $owner = root,
    $group = apache,
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0640,
    $run_mode = 'normal',
    $run_uid = 'absent',
    $run_gid = 'absent',
    $allow_override = 'None',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $php_safe_mode_exec_bins = 'absent',
    $php_default_charset = 'absent',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $mod_security = false,
    $mod_security_relevantonly = true,
    $ssl_mode = false,
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent',
    $manage_config = true,
    $config_webwriteable = false,
    $manage_directories = true,
    $upload_dir = 'present'
){
    $documentroot = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/${name}/www",
            default => "/var/www/vhosts/${name}/www"
        },
        default => "${path}/www"
    }
    $gdatadir = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/${name}/g2data",
            default => "/var/www/vhosts/${name}/g2data"
        },
        default => "${path}/g2data"
    }
    file{$gdatadir:
            ensure => $ensure ? {
              'present' => directory,
              default => absent
            },
            owner => $documentroot_owner, group => $documentroot_group, mode => 0660;
    }

    if ($upload_dir == 'present') or ($upload_dir == 'absent') {
      $real_upload_dir = $operatingsystem ? {
        openbsd => "/var/www/htdocs/${name}/upload",
        default => "/var/www/vhosts/${name}/upload"
      }
    } else {
      $real_upload_dir = $upload_dir
    }

    file{$real_upload_dir:
      owner => $documentroot_owner, group => $documentroot_group, mode => 0660;
    }
    if ($ensure == 'absent') or ($upload_dir == 'absent') {
      File[$real_upload_dir]{
        ensure => absent,
        purge => true,
        force => true,
        recurse => true
      }
    } else {
      File[$real_upload_dir]{
        ensure => directory
      }
    }

    # create vhost configuration file
    ::apache::vhost::php::webapp{$name:
        ensure => $ensure,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        logmode => $logmode,
        path => $path,
        template_mode => 'php_gallery2',
        owner => $owner,
        group => $group,
        documentroot_owner => $documentroot_owner,
        documentroot_group => $documentroot_group,
        documentroot_mode => $documentroot_mode,
        run_mode => $run_mode,
        run_uid => $run_uid,
        run_gid => $run_gid,
        allow_override => $allow_override,
        php_upload_tmp_dir => $php_upload_tmp_dir,
        php_session_save_path => $php_session_save_path,
        php_safe_mode_exec_bins => $real_php_safe_mode_exec_bins,
        php_default_charset => $php_default_charset,
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        mod_security => $mod_security,
        mod_security_relevantonly => $mod_security_relevantonly,
        ssl_mode => $ssl_mode,
        vhost_mode => $vhost_mode,
        vhost_source => $vhost_source,
        vhost_destination => $vhost_destination,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        manage_directories => $manage_directories,
        manage_config => $manage_config,
        config_file => 'config.php',
    }

}

