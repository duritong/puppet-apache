# template_mode:
#   - php: for a default php application
#   - static: for a static application (default)
#   - perl: for a mod_perl application
#   - php_joomla: for a joomla application
#
# domainalias:
#   - absent: no domainalias is set (*default*)
#   - www: domainalias is set to www.$domain
#   - else: domainalias is set to that
#
# ssl_mode: wether this vhost supports ssl or not
#   - false: don't enable ssl for this vhost (default)
#   - true: enable ssl for this vhost
#   - force: enable ssl and redirect non-ssl to ssl
#   - only: enable ssl only
#
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
#
# run_mode: controls in which mode the vhost should be run, there are different setups
#           possible:
#   - normal: (*default*) run vhost with the current active worker (default: prefork) don't
#             setup anything special
#   - itk: run vhost with the mpm_itk module (Incompatibility: cannot be used in combination
#          with 'proxy-itk' & 'static-itk' mode)
#   - proxy-itk: run vhost with a dual prefork/itk setup, where prefork just proxies all the
#                requests for the itk setup, that listens only on the loobpack device.
#                (Incompatibility: cannot be used in combination with the itk setup.)
#   - static-itk: run vhost with a dual prefork/itk setup, where prefork serves all the static
#                 content and proxies the dynamic calls to the itk setup, that listens only on
#                 the loobpack device (Incompatibility: cannot be used in combination with
#                 'itk' mode)
#
# run_uid: the uid the vhost should run as with the itk module
# run_gid: the gid the vhost should run as with the itk module
#
# mod_security: Whether we use mod_security or not (will include mod_security module)
#    - false: don't activate mod_security
#    - true: (*default*) activate mod_security
#
define apache::vhost::template(
    $ensure = present,
    $path = 'absent',
    $path_is_webdir = false,
    $logpath = 'absent',
    $logmode = 'default',
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $allow_override = 'None',
    $php_safe_mode_exec_bin_dir = 'absent',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $dav_db_dir = 'absent',
    $cgi_binpath = 'absent',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $php_use_smarty = false,
    $php_use_pear = false,
    $php_safe_mode = true,
    $php_default_charset = 'absent',
    $php_settings = {},
    $run_mode = 'normal',
    $run_uid = 'absent',
    $run_gid = 'absent',
    $template_mode = 'static',
    $template_partial = 'absent',
    $ssl_mode = false,
    $mod_security = true,
    $mod_security_relevantonly = true,
    $mod_security_rules_to_disable = [],
    $mod_security_additional_options = 'absent',
    $use_mod_macro = false,
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent',
    $ldap_auth = false,
    $ldap_user = 'any'
){
    $real_path = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/$name",
            default => "/var/www/vhosts/$name"
        },
        default => $path
    }

    if $path_is_webdir {
        $documentroot = "$real_path"
    } else {
        $documentroot = "$real_path/www"
    }
    $logdir = $logpath ? {
        'absent' => "$real_path/logs",
        default => $logpath
    }

    $servername = $domain ? {
        'absent' => $name,
        default => $domain
    }
    $serveralias = $domainalias ? {
        'absent' => '',
        'www' => "www.${servername}",
        default => $domainalias
    }
    if $htpasswd_path == 'absent' {
      $real_htpasswd_path = "/var/www/htpasswds/$name"
    } else {
      $real_htpasswd_path = $htpasswd_path
    }
    case $run_mode {
        'proxy-itk': { $logfileprefix = 'proxy' }
        'static-itk': { $logfileprefix = 'static' }
    }
    case $run_mode {
        'itk','proxy-itk','static-itk': {
            case $run_uid {
                'absent': { fail("you have to define run_uid for $name on $fqdn") }
            }
            case $run_gid {
                'absent': { fail("you have to define run_gid for $name on $fqdn") }
            }
        }
    }

    # set default dirs for templates
    # php php_safe_mode_exec_bin directory
    case $php_safe_mode_exec_bin_dir {
        'absent': {
            $real_php_safe_mode_exec_bin_dir = "/var/www/vhosts/$name/bin"
        }
        default: { $real_php_safe_mode_exec_bin_dir = $php_safe_mode_exec_bin_dir }
    }
    # php upload_tmp_dir
    case $php_upload_tmp_dir {
        'absent': {
            $real_php_upload_tmp_dir = "/var/www/upload_tmp_dir/$name"
        }
        default: { $real_php_upload_tmp_dir = $php_upload_tmp_dir }
    }
    # php session_save_path
    case $php_session_save_path {
        'absent': {
            $real_php_session_save_path = "/var/www/session.save_path/$name"
        }
        default: { $real_php_session_save_path = $php_session_save_path }
    }
    # dav db dir
    case $dav_db_dir {
        'absent': {
            $real_dav_db_dir = "/var/www/dav_db_dir/$name"
        }
        default: { $real_dav_db_dir = $dav_db_dir }
    }

    apache::vhost::file{$name:
        ensure => $ensure,
        do_includes => $do_includes,
        run_mode => $run_mode,
        ssl_mode => $ssl_mode,
        logmode => $logmode,
        mod_security => $mod_security,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        use_mod_macro => $use_mod_macro,
    }
    if $ensure != 'absent' {
      Apache::Vhost::File[$name]{
        content => $template_partial ? {
          'absent' => template("apache/vhosts/$template_mode/$operatingsystem.erb"),
          default => template("apache/vhosts/default.erb"),
        }
      }
    }
}

