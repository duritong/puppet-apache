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
define apache::vhost::php::webapp(
    $ensure = present,
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $logmode = 'default',
    $path = 'absent',
    $manage_webdir = true,
    $manage_docroot = true,
    $template_mode,
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
    $php_settings = {},
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $mod_security = true,
    $mod_security_relevantonly = true,
    $mod_security_rules_to_disable = [],
    $mod_security_additional_options = 'absent',
    $ssl_mode = false,
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent',
    $manage_config = true,
    $config_file = 'absent',
    $config_webwriteable = false,
    $manage_directories = true,
    $managed_directories = 'absent'
){
    if ($ensure != 'absent') {
        if $manage_directories and ($managed_directories != 'absent') {
            ::apache::file::rw{ $managed_directories :
                owner => $documentroot_owner,
                group => $documentroot_group,
            }
        }

        if $manage_config {
            if $config_file == 'absent' { fail("No config file defined for ${name} on ${fqdn}, if you'd like to manage the config, you have to add one!") }
            ::apache::vhost::file::documentrootfile{"configurationfile_${name}":
                documentroot => $documentroot,
                filename => $config_file,
                thedomain => $name,
                owner => $documentroot_owner,
                group => $documentroot_group,
            }
            if $config_webwriteable {
                Apache::Vhost::File::Documentrootfile["configurationfile_${name}"]{
                    mode => 0660,
                }
            } else {
                Apache::Vhost::File::Documentrootfile["configurationfile_${name}"]{
                    mode => 0440,
                }
            }
        }
    }

    # create vhost configuration file
    ::apache::vhost::php::standard{$name:
        ensure => $ensure,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        logmode => $logmode,
        path => $path,
        manage_webdir => $manage_webdir,
        manage_docroot => $manage_docroot,
        template_mode => $template_mode,
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
        php_settings => $php_settings,
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        mod_security => $mod_security,
        mod_security_relevantonly => $mod_security_relevantonly,
        mod_security_rules_to_disable => $mod_security_rules_to_disable,
        mod_security_additional_options => $mod_security_additional_options,
        ssl_mode => $ssl_mode,
        vhost_mode => $vhost_mode,
        vhost_source => $vhost_source,
        vhost_destination => $vhost_destination,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
    }
}

