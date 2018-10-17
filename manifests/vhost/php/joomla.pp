# run_mode: controls in which mode the vhost should be run, there are different
#           setups possible:
#   - normal: (*default*) run vhost with the current active worker
#             (default: prefork) don't setup anything special
#   - fcgid run vhost with the fcgid module and suexec
#
# run_uid: the uid the vhost should run as with the suexec module
# run_gid: the gid the vhost should run as with the suexec module
#
# mod_security: Whether we use mod_security or not (will include mod_security
#               module)
#    - false: don't activate mod_security
#    - true: (*default*) activate mod_security
#
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
define apache::vhost::php::joomla(
  $ensure                           = present,
  $configuration                    = {},
  $domain                           = 'absent',
  $domainalias                      = 'absent',
  $server_admin                     = 'absent',
  $logmode                          = 'default',
  $path                             = 'absent',
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
  $php_installation                 = 'system',
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
  $template_partial                 = 'apache/vhosts/php_joomla/partial.erb',
  $vhost_source                     = 'absent',
  $vhost_destination                = 'absent',
  $htpasswd_file                    = 'absent',
  $htpasswd_path                    = 'absent',
  $manage_config                    = true,
  $config_webwriteable              = false,
  $manage_directories               = true
){
  include ::apache::include::joomla

  $documentroot = $path ? {
    'absent' => "/var/www/vhosts/${name}/www",
    default => "${path}/www",
  }

  if $mod_security_additional_options == 'absent' {
    $id_str = $::operatingsystem ? {
      'CentOS'  => $::operatingsystemmajrelease ? {
        '5'     => '',
        default => 'id:1199400,'
      },
      default => ''
    }
    $real_mod_security_additional_options = "
    # http://optics.csufresno.edu/~kriehn/fedora/fedora_files/f9/howto/modsecurity.html
    # Exceptions for Joomla Root Directory
    <LocationMatch \"^/\">
        SecRuleRemoveById 950013
    </LocationMatch>

    # Exceptions for Joomla Administration Panel
    SecRule REQUEST_FILENAME \"/administrator/index2.php\" \"${id_str}allow,phase:1,nolog,ctl:ruleEngine=Off\"

    # Exceptions for Joomla Component Expose
    <LocationMatch \"^/components/com_expose/expose/manager/amfphp/gateway.php\">
        SecRuleRemoveById 960010
    </LocationMatch>
"
  } else {
    $real_mod_security_additional_options = $mod_security_additional_options
  }

  $std_joomla_php_settings = {
    'allow_url_fopen'   => 'on',
    'allow_url_include' => 'off',
  }

  # create vhost configuration file
  ::apache::vhost::php::webapp{
    $name:
      ensure                          => $ensure,
      configuration                   => $configuration,
      domain                          => $domain,
      domainalias                     => $domainalias,
      server_admin                    => $server_admin,
      logmode                         => $logmode,
      path                            => $path,
      owner                           => $owner,
      group                           => $group,
      documentroot_owner              => $documentroot_owner,
      documentroot_group              => $documentroot_group,
      documentroot_mode               => $documentroot_mode,
      run_mode                        => $run_mode,
      run_uid                         => $run_uid,
      run_gid                         => $run_gid,
      allow_override                  => $allow_override,
      php_settings                    => merge($std_joomla_php_settings,
        $php_settings),
      php_options                     => $php_options,
      php_installation                => $php_installation,
      do_includes                     => $do_includes,
      options                         => $options,
      additional_options              => $additional_options,
      default_charset                 => $default_charset,
      mod_security                    => $mod_security,
      mod_security_relevantonly       => $mod_security_relevantonly,
      mod_security_rules_to_disable   => $mod_security_rules_to_disable,
      mod_security_additional_options => $real_mod_security_additional_options,
      ssl_mode                        => $ssl_mode,
      vhost_mode                      => $vhost_mode,
      template_partial                => $template_partial,
      vhost_source                    => $vhost_source,
      vhost_destination               => $vhost_destination,
      htpasswd_file                   => $htpasswd_file,
      htpasswd_path                   => $htpasswd_path,
      manage_directories              => $manage_directories,
      managed_directories             => [ "${documentroot}/administrator/backups",
                                            "${documentroot}/administrator/components",
                                            "${documentroot}/administrator/language",
                                            "${documentroot}/administrator/modules",
                                            "${documentroot}/administrator/templates",
                                            "${documentroot}/components",
                                            "${documentroot}/dmdocuments",
                                            "${documentroot}/images",
                                            "${documentroot}/language",
                                            "${documentroot}/media",
                                            "${documentroot}/modules",
                                            "${documentroot}/plugins",
                                            "${documentroot}/templates",
                                            "${documentroot}/cache",
                                            "${documentroot}/tmp",
                                            "${documentroot}/administrator/cache" ],
      manage_config                   => $manage_config,
      config_webwriteable             => $config_webwriteable,
      config_file                     => 'configuration.php',
  }

}

