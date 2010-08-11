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
define apache::vhost::php::spip(
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
    $allow_override = 'FileInfo',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $php_safe_mode_exec_bins = 'absent',
    $php_default_charset = 'absent',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $mod_security = true,
    $mod_security_relevantonly = true,
    $ssl_mode = false,
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent'
){
    $documentroot = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/${name}/www",
            default => "/var/www/vhosts/${name}/www"
        },
        default => "${path}/www"
    }

    # create vhost configuration file
    ::apache::vhost::php::webapp{$name:
        ensure => $ensure,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        logmode => $logmode,
        path => $path,
        template_mode => 'php_spip',
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
        php_safe_mode_exec_bins => $php_safe_mode_exec_bins,
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
        managed_directories => [ "$documentroot/IMG", "$documentroot/tmp", "$documentroot/local", "$documentroot/config" ],
        manage_config => false,
    }
}

