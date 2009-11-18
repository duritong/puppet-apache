# run_mode:
#   - normal: nothing special (*default*)
#   - itk: apache is running with the itk module
#          and run_uid and run_gid are used as vhost users
# run_uid: the uid the vhost should run as with the itk module
# run_gid: the gid the vhost should run as with the itk module
define apache::vhost::php::webapp(
    $ensure = present,
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
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
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $mod_security = true,
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
    $managed_directories = 'absent',
    $php_safe_mode_exec_bins = 'absent'
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
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        mod_security => $mod_security,
        ssl_mode => $ssl_mode,
        vhost_mode => $vhost_mode,
        vhost_source => $vhost_source,
        vhost_destination => $vhost_destination,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        php_safe_mode_exec_bins => $php_safe_mode_exec_bins
    }
}

