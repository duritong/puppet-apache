# template_partial:
#  which template should be used to generate the type specific part
#  of the vhost entry.
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
#   - fcgid:  run vhost with a fcgid / suexec setup
#
# run_uid: the uid the vhost should run as with the suexec module
# run_gid: the gid the vhost should run as with the suexec module
#
# mod_security: Whether we use mod_security or not (will include mod_security module)
#    - false: don't activate mod_security
#    - true: (*default*) activate mod_security
#
define apache::vhost::template(
  $ensure                          = present,
  $configuration                   = {},
  $path                            = 'absent',
  $path_is_webdir                  = false,
  $logpath                         = 'absent',
  $logmode                         = 'default',
  $logprefix                       = '',
  $domain                          = 'absent',
  $domainalias                     = 'absent',
  $server_admin                    = 'absent',
  $allow_override                  = 'None',
  $cgi_binpath                     = 'absent',
  $do_includes                     = false,
  $options                         = 'absent',
  $additional_options              = 'absent',
  $default_charset                 = 'absent',
  $php_options                     = {},
  $php_settings                    = {},
  $run_mode                        = 'normal',
  $run_uid                         = 'absent',
  $run_gid                         = 'absent',
  $template_partial                = 'apache/vhosts/static/partial.erb',
  $template_vars                   = {},
  $ssl_mode                        = false,
  $mod_security                    = false,
  $mod_security_relevantonly       = true,
  $mod_security_rules_to_disable   = [],
  $mod_security_additional_options = 'absent',
  $use_mod_macro                   = false,
  $htpasswd_file                   = 'absent',
  $htpasswd_path                   = 'absent',
  $passing_extension               = 'absent',
  $gempath                         = 'absent'
){
  $real_path = $path ? {
    'absent' => "/var/www/vhosts/${name}",
    default  => $path,
  }

  if 'documentroot' in $configuration {
    if $configuration['documentroot'] =~ Stdlib::Unixpath {
      $documentroot = $configuration['documentroot']
    } else {
      $documentroot = "${real_path}/${configuration['documentroot']}"
    }
  } elsif $path_is_webdir {
    $documentroot = $real_path
  } else {
    $documentroot = "${real_path}/www"
  }
  $logdir = $logpath ? {
    'absent' => "${real_path}/logs",
    default  => $logpath
  }

  $servername = $domain ? {
    'absent' => $name,
    default  => $domain
  }
  $serveralias = $domainalias ? {
    'absent' => '',
    'www'    => "www.${servername}",
    default  => $domainalias
  }
  if $htpasswd_path == 'absent' {
    $real_htpasswd_path = "/var/www/htpasswds/${name}"
  } else {
    $real_htpasswd_path = $htpasswd_path
  }
  if $run_mode == 'fcgid' {
    if $run_uid == 'absent' { fail("you have to define run_uid for ${name} on ${::fqdn}") }
    if $run_gid == 'absent' { fail("you have to define run_gid for ${name} on ${::fqdn}") }
  }

  apache::vhost::file{$name:
    ensure        => $ensure,
    configuration => $configuration,
    do_includes   => $do_includes,
    run_mode      => $run_mode,
    ssl_mode      => $ssl_mode,
    logmode       => $logmode,
    mod_security  => $mod_security,
    htpasswd_file => $htpasswd_file,
    htpasswd_path => $htpasswd_path,
    use_mod_macro => $use_mod_macro,
  }
  if $ensure != 'absent' {
    Apache::Vhost::File[$name]{
      content => template('apache/vhosts/default.erb'),
    }
  }
}

