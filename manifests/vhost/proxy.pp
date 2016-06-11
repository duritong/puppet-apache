# Proxy VHost
# Parameters:
#
# - ensure: wether this vhost is `present` or `absent`
# - domain: the domain to redirect (*name*)
# - domainalias: A list of whitespace seperated domains to redirect
# - backend: the url to be proxied. Note: We don't want http://example.com/foobar/ only http://example.com/foobar
# - server_admin: the email that is shown as responsible
# - ssl_mode: wether this vhost supports ssl or not
#   - false: don't enable ssl for this vhost (default)
#   - true: enable ssl for this vhost
#   - force: enable ssl and redirect non-ssl to ssl
#   - only: enable ssl only
#
# logmode:
#
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
#
define apache::vhost::proxy(
  $backend,
  $ensure                          = present,
  $configuration                   = {},
  $domain                          = 'absent',
  $domainalias                     = 'absent',
  $htpasswd_file                   = 'absent',
  $server_admin                    = 'absent',
  $logmode                         = 'default',
  $logpath                         = 'absent',
  $mod_security                    = false,
  $ssl_mode                        = false,
  $mod_security_relevantonly       = true,
  $mod_security_rules_to_disable   = [],
  $mod_security_additional_options = 'absent',
  $additional_options              = 'absent'
){
  $real_logpath = $logpath ? {
    'absent' => $::operatingsystem ? {
      'CentOS' => '/var/log/httpd',
      default  => '/var/log/apache2'
    },
    default => $logpath,
  }
  # create vhost configuration file
  # we use the options field as the target_url
  ::apache::vhost::template{$name:
    ensure                          => $ensure,
    configuration                   => $configuration,
    template_partial                => 'apache/vhosts/proxy/partial.erb',
    domain                          => $domain,
    path                            => 'really_absent',
    path_is_webdir                  => true,
    htpasswd_file                   => $htpasswd_file,
    domainalias                     => $domainalias,
    server_admin                    => $server_admin,
    logpath                         => $real_logpath,
    logmode                         => $logmode,
    run_mode                        => 'normal',
    mod_security                    => $mod_security,
    mod_security_relevantonly       => $mod_security_relevantonly,
    mod_security_rules_to_disable   => $mod_security_rules_to_disable,
    mod_security_additional_options => $mod_security_additional_options,
    options                         => $backend, # we abuse the options param
                                                  # to be used in the template
    ssl_mode                        => $ssl_mode,
    additional_options              => $additional_options,
  }
}

