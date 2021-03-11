# run_mode: controls in which mode the vhost should be run, there are different setups
#           possible:
#   - normal: (*default*) run vhost with the current active worker (default: prefork) don't
#             setup anything special
#   - fcgid: run vhost with the fcgid module and suexec
#
# run_uid: the uid the vhost should run as with the suexec module
# run_gid: the gid the vhost should run as with the suexec module
#
# mod_security: Whether we use mod_security or not (will include mod_security module)
#    - false: don't activate mod_security
#    - true: (*default*) activate mod_security
#
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
define apache::vhost::php::webapp (
  $template_partial,
  $ensure                           = present,
  $configuration                    = {},
  $domain                           = 'absent',
  $domainalias                      = 'absent',
  $server_admin                     = 'absent',
  $logmode                          = 'default',
  $path                             = 'absent',
  $manage_webdir                    = true,
  $manage_docroot                   = true,
  $owner                            = root,
  $group                            = apache,
  $documentroot_owner               = apache,
  $documentroot_group               = 0,
  $documentroot_mode                = '0640',
  $run_mode                         = 'normal',
  $run_uid                          = 'absent',
  $run_gid                          = 'absent',
  $allow_override                   = 'None',
  $php_settings                     = {},
  $php_options                      = {},
  $php_installation                 = 'scl74',
  $do_includes                      = false,
  $options                          = 'absent',
  $additional_options               = 'absent',
  $default_charset                  = 'absent',
  $mod_security                     = false,
  $mod_security_relevantonly        = true,
  $mod_security_rules_to_disable    = [],
  $mod_security_additional_options  = 'absent',
  $ssl_mode                         = false,
  $vhost_mode                       = 'template',
  $vhost_source                     = 'absent',
  $vhost_destination                = 'absent',
  $htpasswd_file                    = 'absent',
  $htpasswd_path                    = 'absent',
  $manage_config                    = true,
  $config_file                      = 'absent',
  $config_webwriteable              = false,
  $manage_directories               = true,
  $managed_directories              = 'absent',
) {
  if ($ensure != 'absent') {
    if $manage_directories and ($managed_directories != 'absent') {
      apache::vhost::managed_directory { $managed_directories :
        owner => $documentroot_owner,
        group => $documentroot_group,
      }
    }

    if $manage_config {
      if $config_file == 'absent' { fail("No config file defined for ${name} on ${facts['networking']['fqdn']}, if you'd like to manage the config, you have to add one!") }

      $real_path = $path ? {
        'absent' => "/var/www/vhosts/${name}",
        default  => $path,
      }
      $documentroot = "${real_path}/www"
      apache::vhost::file::documentrootfile { "configurationfile_${name}":
        documentroot => $documentroot,
        filename     => $config_file,
        thedomain    => $name,
        owner        => $documentroot_owner,
        group        => $documentroot_group,
      }
      if $config_webwriteable {
        Apache::Vhost::File::Documentrootfile["configurationfile_${name}"] {
          mode => '0660',
        }
      } else {
        Apache::Vhost::File::Documentrootfile["configurationfile_${name}"] {
          mode => '0440',
        }
      }
    }
  }

  # create vhost configuration file
  apache::vhost::php::standard { $name:
    ensure                          => $ensure,
    configuration                   => $configuration,
    domain                          => $domain,
    domainalias                     => $domainalias,
    server_admin                    => $server_admin,
    logmode                         => $logmode,
    path                            => $path,
    manage_webdir                   => $manage_webdir,
    manage_docroot                  => $manage_docroot,
    owner                           => $owner,
    group                           => $group,
    documentroot_owner              => $documentroot_owner,
    documentroot_group              => $documentroot_group,
    documentroot_mode               => $documentroot_mode,
    run_mode                        => $run_mode,
    run_uid                         => $run_uid,
    run_gid                         => $run_gid,
    allow_override                  => $allow_override,
    php_settings                    => $php_settings,
    php_options                     => $php_options,
    php_installation                => $php_installation,
    do_includes                     => $do_includes,
    options                         => $options,
    additional_options              => $additional_options,
    default_charset                 => $default_charset,
    mod_security                    => $mod_security,
    mod_security_relevantonly       => $mod_security_relevantonly,
    mod_security_rules_to_disable   => $mod_security_rules_to_disable,
    mod_security_additional_options => $mod_security_additional_options,
    ssl_mode                        => $ssl_mode,
    vhost_mode                      => $vhost_mode,
    template_partial                => $template_partial,
    vhost_source                    => $vhost_source,
    vhost_destination               => $vhost_destination,
    htpasswd_file                   => $htpasswd_file,
    htpasswd_path                   => $htpasswd_path,
  }
}
