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
define apache::vhost::wsgi(
  $ensure                           = present,
  $configuration                    = {},
  $domain                           = 'absent',
  $domainalias                      = 'absent',
  $server_admin                     = 'absent',
  $logmode                          = 'default',
  $logpath                          = 'absent',
  $logprefix                        = '',
  $path                             = 'absent',
  $manage_webdir                    = true,
  $path_is_webdir                   = false,
  $manage_docroot                   = true,
  $owner                            = root,
  $group                            = apache,
  $documentroot_owner               = apache,
  $documentroot_group               = 0,
  $documentroot_mode                = '0640',
  $run_uid                          = 'absent',
  $run_gid                          = 'absent',
  $allow_override                   = 'None',
  $php_settings                     = {},
  $php_options                      = {},
  $php_installation                 = 'system',
  $do_includes                      = false,
  $options                          = 'absent',
  $additional_options               = 'absent',
  $default_charset                  = 'absent',
  $use_mod_macro                    = false,
  $mod_security                     = true,
  $mod_security_relevantonly        = true,
  $mod_security_rules_to_disable    = [],
  $mod_security_additional_options  = 'absent',
  $ssl_mode                         = false,
  $vhost_mode                       = 'template',
  $template_partial                 = 'apache/vhosts/python/partial.erb',
  $vhost_source                     = 'absent',
  $vhost_destination                = 'absent',
  $htpasswd_file                    = 'absent',
  $htpasswd_path                    = 'absent',
){

  require "::python::scl36::wsgi"

  if $manage_webdir {
    # create webdir
    ::apache::vhost::webdir{$name:
      ensure             => $ensure,
      path               => $path,
      owner              => $owner,
      group              => $group,
      manage_docroot     => $manage_docroot,
      documentroot_owner => $documentroot_owner,
      documentroot_group => $documentroot_group,
      documentroot_mode  => $documentroot_mode,
    }
  }

  $real_path = $path ? {
    'absent' => "/var/www/vhosts/${name}",
    default  => $path,
  }

  if $path_is_webdir {
    $documentroot = $real_path
  } else {
    $documentroot = "${real_path}/www"
  }
  $logdir = $logpath ? {
    'absent' => "${real_path}/logs",
    default  => $logpath
  }

  $new_config = merge($configuration,
                      {wsgi => true})

  # create vhost configuration file
  ::apache::vhost{$name:
    ensure                          => $ensure,
    configuration                   => $new_config,
    path                            => $path,
    path_is_webdir                  => $path_is_webdir,
    vhost_mode                      => $vhost_mode,
    template_partial                => $template_partial,
    vhost_source                    => $vhost_source,
    vhost_destination               => $vhost_destination,
    domain                          => $domain,
    domainalias                     => $domainalias,
    server_admin                    => $server_admin,
    logmode                         => $logmode,
    logpath                         => $logpath,
    logprefix                       => $logprefix,
    run_uid                         => $run_uid,
    run_gid                         => $run_gid,
    allow_override                  => $allow_override,
    do_includes                     => $do_includes,
    options                         => $options,
    additional_options              => $additional_options,
    default_charset                 => $default_charset,
    ssl_mode                        => $ssl_mode,
    htpasswd_file                   => $htpasswd_file,
    htpasswd_path                   => $htpasswd_path,
    mod_security                    => $mod_security,
    mod_security_relevantonly       => $mod_security_relevantonly,
    mod_security_rules_to_disable   => $mod_security_rules_to_disable,
    mod_security_additional_options => $mod_security_additional_options,
    use_mod_macro                   => $use_mod_macro,
  }
  if $ensure != 'absent' {
    file{
      ["${real_path}/virtualenv"]:
        ensure => directory,
        owner  => $documentroot_owner,
        group  => $group,
        mode   => '0660';
    }
  }
}
