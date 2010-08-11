# run_uid: the uid the vhost should run as with the mod_passenger module
# run_gid: the gid the vhost should run as with the mod_passenger module
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
define apache::vhost::passenger(
    $ensure = present,
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $logmode = 'default',
    $path = 'absent',
    $manage_webdir = true,
    $manage_docroot = true,
    $template_mode = 'passenger',
    $owner = root,
    $group = apache,
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0640,
    # TODO: think of a more generic way to handle user separation 
    # i.e. rename itk mode into something else
    # e.g. default, moderate (use same user for access and run), strict (use different users for access and run)
    $run_mode = 'normal',
    $run_uid = 'absent',
    $run_gid = 'absent',
    $allow_override = 'None',
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
    if $manage_webdir {
      # create webdir
      ::apache::vhost::webdir{$name:
        ensure => $ensure,
        path => $path,
        owner => $owner,
        group => $group,
        run_mode => $run_mode,
        manage_docroot => $manage_docroot,
        documentroot_owner => $documentroot_owner,
        documentroot_group => $documentroot_group,
        documentroot_mode => $documentroot_mode,
      }
    }

    # create vhost configuration file
    ::apache::vhost{$name:
        ensure => $ensure,
        path => $path,
        template_mode => $template_mode,
        logmode => $logmode,
        vhost_mode => $vhost_mode,
        vhost_source => $vhost_source,
        vhost_destination => $vhost_destination,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        run_mode => 'itk',
        run_uid => $run_uid,
        run_gid => $run_gid,
        allow_override => $allow_override,
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        ssl_mode => $ssl_mode,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        mod_security => $mod_security,
        mod_security_relevantonly => $mod_security_relevantonly,
    }
}

