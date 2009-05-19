define apache::vhost::gitweb(
    $ensure = present,
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $owner = root,
    $group = 0,
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0640,
    $allow_override = 'None',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $ssl_mode = false,
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent'
){
    # create vhost configuration file
    ::apache::vhost{$name:
        ensure => $ensure,
        path => '/var/www/git',
        path_is_webdir => true,
        template_mode => 'gitweb',
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        allow_override => $allow_override,
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        ssl_mode => $ssl_mode,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        mod_security => false,
    }
}

