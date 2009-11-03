# this is a wrapper for apache::vhost::file and avhost::template below
#
# vhost_mode: which option is choosed to deploy the vhost
#   - template: generate it from a template (default)
#   - file: deploy a vhost file (apache::vhost::file will be called directly)
#   
define apache::vhost(
    $ensure = present,
    $path = 'absent',
    $path_is_webdir = false,
    $logpath = 'absent',
    $template_mode = 'static',
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $content = 'absent',
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $allow_override = 'None',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $php_use_smarty = false,
    $php_use_pear = false,
    $php_safe_mode = true,
    $cgi_binpath = 'absent',
    $default_charset = 'absent',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $run_mode = 'normal',
    $run_uid = 'absent',
    $run_gid = 'absent',
    $template_mode = 'static',
    $ssl_mode = false,
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent',
    $mod_security = true,
    $use_mod_macro = false,
    $ldap_auth = false,
    $ldap_user = 'any'
) {
    # file or template mode?
    case $vhost_mode {
        'file': {
            apache::vhost::file{$name:
                ensure => $ensure,
                vhost_source => $vhost_source,
                vhost_destination => $vhost_destination,
                do_includes => $do_includes,
                htpasswd_file => $htpasswd_file,
                htpasswd_path => $htpasswd_path,
                use_mod_macro => $use_mod_macro,
            }
        }
        'template': {
            apache::vhost::template{$name:
                ensure => $ensure,
                path => $path,
                path_is_webdir => $path_is_webdir,
                logpath => $logpath,
                domain => $domain,
                domainalias => $domainalias,
                server_admin => $server_admin,
                php_upload_tmp_dir => $php_upload_tmp_dir,
                php_session_save_path => $php_session_save_path,
                cgi_binpath => $cgi_binpath,
                allow_override => $allow_override,
                do_includes => $do_includes,
                options => $options,
                additional_options => $additional_options,
                default_charset => $default_charset,
                php_use_smarty => $php_use_smarty,
                php_use_pear => $php_use_pear,
                php_safe_mode => $php_safe_mode,
                run_mode => $run_mode,
                run_uid => $run_uid,
                run_gid => $run_gid,
                template_mode => $template_mode,
                ssl_mode => $ssl_mode,
                htpasswd_file => $htpasswd_file,
                htpasswd_path => $htpasswd_path,
                ldap_auth => $ldap_auth,
                ldap_user => $ldap_user,
                mod_security => $mod_security,
                use_mod_macro => $use_mod_macro,
            }
        }
        default: { fail("no such vhost_mode: $vhost_mode defined for $name.") }
    }

}
