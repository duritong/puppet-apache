# Webdav vhost: to manage webdav accessible targets
# run_mode:
#   - normal: nothing special (*default*)
#   - itk: apache is running with the itk module
#          and run_uid and run_gid are used as vhost users
# run_uid: the uid the vhost should run as with the itk module
# run_gid: the gid the vhost should run as with the itk module
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
define apache::vhost::webdav(
    $ensure = present,
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $logmode = 'default',
    $path = 'absent',
    $owner = root,
    $group = apache,
    $manage_webdir = true,
    $path_is_webdir = false,
    $logpath = 'absent',
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0640,
    $run_mode = 'normal',
    $run_uid = 'absent',
    $run_gid = 'absent',
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
    $ldap_auth = false,
    $ldap_user = 'any',
    $dav_db_dir = 'absent'
){
    ::apache::vhost::davdbdir{"${name}":
        ensure => $ensure,
        dav_db_dir => $dav_db_dir,
        documentroot_owner => $documentroot_owner,
        documentroot_group => $documentroot_group,
        documentroot_mode => $documentroot_mode,
        run_mode => $run_mode,
        run_uid => $run_uid,
    }

    if $manage_webdir {
        # create webdir
        ::apache::vhost::webdir{$name:
            ensure => $ensure,
            path => $path,
            owner => $owner,
            group => $group,
            run_mode => $run_mode,
            documentroot_owner => $documentroot_owner,
            documentroot_group => $documentroot_group,
            documentroot_mode => $documentroot_mode,
        }
    }
    # create vhost configuration file
    ::apache::vhost{$name:
        ensure => $ensure,
        path => $path,
        path_is_webdir => $path_is_webdir,
        logpath => $logpath,
        logmode => $logmode,
        template_mode => 'webdav',
        vhost_mode => $vhost_mode,
        vhost_source => $vhost_source,
        vhost_destination => $vhost_destination,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        run_mode => $run_mode,
        run_uid => $run_uid,
        run_gid => $run_gid,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        ssl_mode => $ssl_mode,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        ldap_auth => $ldap_auth,
        ldap_user => $ldap_user,
        mod_security => $mod_security,
    }
}

