# run_mode: controls in which mode the vhost should be run, there are different setups
#           possible:
#   - normal: (*default*) run vhost with the current active worker (default: prefork) don't
#             setup anything special
#   - fcgid: run vhost with the fcgid and suexec
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
#
define apache::vhost::modperl(
  $ensure                          = present,
  $configuration                   = configuration,
  $domain                          = 'absent',
  $domainalias                     = 'absent',
  $server_admin                    = 'absent',
  $logmode                         = 'default',
  $path                            = 'absent',
  $owner                           = root,
  $group                           = apache,
  $documentroot_owner              = apache,
  $documentroot_group              = 0,
  $documentroot_mode               = '0640',
  $run_mode                        = 'normal',
  $run_uid                         = 'absent',
  $run_gid                         = 'absent',
  $allow_override                  = 'None',
  $cgi_binpath                     = 'absent',
  $do_includes                     = false,
  $options                         = 'absent',
  $additional_options              = 'absent',
  $default_charset                 = 'absent',
  $mod_security                    = true,
  $mod_security_relevantonly       = true,
  $mod_security_rules_to_disable   = [],
  $mod_security_additional_options = 'absent',
  $ssl_mode                        = false,
  $vhost_mode                      = 'template',
  $template_partial                = 'apache/vhosts/perl/partial.erb',
  $vhost_source                    = 'absent',
  $vhost_destination               = 'absent',
  $htpasswd_file                   = 'absent',
  $htpasswd_path                   = 'absent',
){
  # cgi_bin path
  case $cgi_binpath {
    'absent': {
      $real_path = $path ? {
          'absent' => "/var/www/vhosts/${name}",
          default  => $path,
      }
      $real_cgi_binpath = "${real_path}/cgi-bin"
    }
    default: { $real_cgi_binpath = $cgi_binpath }
  }

  $cgi_ensure = $ensure ? {
    'absent' => 'absent',
    default  => directory,
  }
  file{$real_cgi_binpath:
    ensure => $cgi_ensure,
    owner  => $documentroot_owner,
    group  => $documentroot_group,
    mode   => $documentroot_mode;
  }

  if $ensure != 'absent' {
    case $run_mode {
      'fcgid': {
        include ::mod_fcgid
        include ::apache::include::mod_fcgid
        # we don't need mod_perl if we run it as fcgid
        include ::mod_perl::disable
        mod_fcgid::starter {$name:
          cgi_type => 'perl',
          owner    => $run_uid,
          group    => $run_gid,
          notify   => Service['apache'],
        }
      }
      default: { include ::mod_perl }
    }
  }

  # create webdir
  ::apache::vhost::webdir{$name:
    ensure             => $ensure,
    path               => $path,
    owner              => $owner,
    group              => $group,
    run_mode           => $run_mode,
    documentroot_owner => $documentroot_owner,
    documentroot_group => $documentroot_group,
    documentroot_mode  => $documentroot_mode,
  }

  # create vhost configuration file
  ::apache::vhost{$name:
    ensure                          => $ensure,
    configuration                   => $configuration,
    path                            => $path,
    logmode                         => $logmode,
    vhost_mode                      => $vhost_mode,
    template_partial                => $template_partial,
    vhost_source                    => $vhost_source,
    vhost_destination               => $vhost_destination,
    domain                          => $domain,
    domainalias                     => $domainalias,
    server_admin                    => $server_admin,
    run_mode                        => $run_mode,
    run_uid                         => $run_uid,
    run_gid                         => $run_gid,
    allow_override                  => $allow_override,
    do_includes                     => $do_includes,
    options                         => $options,
    additional_options              => $additional_options,
    default_charset                 => $default_charset,
    cgi_binpath                     => $real_cgi_binpath,
    ssl_mode                        => $ssl_mode,
    htpasswd_file                   => $htpasswd_file,
    htpasswd_path                   => $htpasswd_path,
    mod_security                    => $mod_security,
    mod_security_relevantonly       => $mod_security_relevantonly,
    mod_security_rules_to_disable   => $mod_security_rules_to_disable,
    mod_security_additional_options => $mod_security_additional_options,
    passing_extension               => 'pl',
  }
}

