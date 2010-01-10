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
define apache::vhost::php::standard(
    $ensure = present,
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $path = 'absent',
    $manage_webdir = true,
    $manage_docroot = true,
    $template_mode = 'php',
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
    $php_use_smarty = false,
    $php_use_pear = false,
    $php_safe_mode = true,
    $php_safe_mode_exec_bins = 'absent',
    $php_default_charset = 'absent',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $use_mod_macro = false,
    $mod_security = true,
    $ssl_mode = false,
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent'
){

    $real_php_default_charset = $php_default_charset ? {
      'absent' => $default_charset ? {
        'On' => 'iso-8859-1',
        default => $default_charset
      },
      default => $php_default_charset
    }

    ::apache::vhost::phpdirs{"${name}":
        ensure => $ensure,
        php_upload_tmp_dir => $php_upload_tmp_dir,
        php_session_save_path => $php_session_save_path,
        documentroot_owner => $documentroot_owner,
        documentroot_group => $documentroot_group,
        documentroot_mode => $documentroot_mode,
        run_mode => $run_mode,
        run_uid => $run_uid,
    }

    $php_safe_mode_exec_bin_dir = $path ? {
      'absent' => $operatingsystem ? {
        openbsd => "/var/www/htdocs/${name}/bin",
        default => "/var/www/vhosts/${name}/bin"
      },
      default => "${path}/bin"
    }
    file{$php_safe_mode_exec_bin_dir:
      recurse => true,
      force => true,
      purge => true,
    }
    if $php_safe_mode_exec_bins != 'absent' {
     File[$php_safe_mode_exec_bin_dir]{
        ensure => $ensure ? {
          'present' => directory,
          default => absent,
        },
        source => "puppet://$server/modules/common/empty",
        owner => $documentroot_owner, group => $documentroot_group, mode => 0750,
      }
      $php_safe_mode_exec_bins_subst = regsubst($php_safe_mode_exec_bins,"(.+)","${name}_\\1")
      apache::vhost::php::safe_mode_bin{ $php_safe_mode_exec_bins_subst:
        ensure => $ensure,
        path => $php_safe_mode_exec_bin_dir
      }
    }else{
      File[$php_safe_mode_exec_bin_dir]{
        ensure => absent,
      }
    }

    if $php_use_smarty {
        include php::extensions::smarty
    }

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
        vhost_mode => $vhost_mode,
        vhost_source => $vhost_source,
        vhost_destination => $vhost_destination,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        run_mode => $run_mode,
        run_uid => $run_uid,
        run_gid => $run_gid,
        allow_override => $allow_override,
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        php_safe_mode_exec_bin_dir => $php_safe_mode_exec_bin_dir,
        php_upload_tmp_dir => $php_upload_tmp_dir,
        php_session_save_path => $php_session_save_path,
        php_use_smarty => $php_use_smarty,
        php_use_pear => $php_use_pear,
        php_safe_mode => $php_safe_mode,
        php_default_charset => $real_php_default_charset,
        ssl_mode => $ssl_mode,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        mod_security => $mod_security,
        use_mod_macro => $use_mod_macro,
    }
}

