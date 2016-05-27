# htpasswd_file: wether to deploy a passwd for this vhost or not
#   - absent: ignore (default)
#   - nodeploy: htpasswd file isn't deployed by this mechanism
#   - else: try to deploy the file
#
# htpasswd_path: where to deploy the passwd file
#   - absent: standardpath (default)
#   - else: path to deploy
#
# ssl_mode: wether this vhost supports ssl or not
#   - false: don't enable ssl for this vhost (default)
#   - true: enable ssl for this vhost
#   - force: enable ssl and redirect non-ssl to ssl
#   - only: enable ssl only
#
# run_mode: controls in which mode the vhost should be run, there are different setups
#           possible:
#   - normal: (*default*) run vhost with the current active worker (default: prefork) don't
#             setup anything special
#   - fcgid: run vhost with the fcgid module and suexec
#
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
#
#
# mod_security: Whether we use mod_security or not
#               (will include mod_security module)
#    - false: (*default*) don't activate mod_security
#    - true: activate mod_security
#
define apache::vhost::file(
    $ensure             = present,
    $configuration      = {},
    $vhost_source       = 'absent',
    $vhost_destination  = 'absent',
    $content            = 'absent',
    $do_includes        = false,
    $run_mode           = 'normal',
    $logmode            = 'default',
    $ssl_mode           = false,
    $mod_security       = false,
    $htpasswd_file      = 'absent',
    $htpasswd_path      = 'absent',
    $use_mod_macro      = false
){
  $vhosts_dir = $::operatingsystem ? {
    /^(Debian|Ubuntu)$/ => "${apache::config_dir}/sites-enabled",
    default             => "${apache::config_dir}/vhosts.d",
  }
  $real_vhost_destination = $vhost_destination ? {
    'absent'  => "${vhosts_dir}/${name}.conf",
    default   => $vhost_destination,
  }
  file{"${name}.conf":
    ensure  => $ensure,
    path    => $real_vhost_destination,
    require => File['vhosts_dir'],
    notify  => Service[apache],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
  if $ensure != 'absent' {
    if $do_includes {
      include ::apache::includes
    }
    if $use_mod_macro {
      include ::apache::mod_macro
    }
    if $logmode in ['semianonym','anonym'] {
      include ::apache::noiplog
    }
    if $mod_security { include ::mod_security }

    case $content {
      'absent': {
        $real_vhost_source = $vhost_source ? {
          'absent'  => [
            "puppet:///modules/site_apache/vhosts.d/${::fqdn}/${name}.conf",
            "puppet:///modules/site_apache/vhosts.d/${apache::cluster_node}/${name}.conf",
            "puppet:///modules/site_apache/vhosts.d/${::operatingsystem}.${::operatingsystemmajrelease}/${name}.conf",
            "puppet:///modules/site_apache/vhosts.d/${::operatingsystem}/${name}.conf",
            "puppet:///modules/site_apache/vhosts.d/${name}.conf",
            "puppet:///modules/apache/vhosts.d/${::operatingsystem}.${::operatingsystemmajrelease}/${name}.conf",
            "puppet:///modules/apache/vhosts.d/${::operatingsystem}/${name}.conf",
            "puppet:///modules/apache/vhosts.d/${name}.conf"
          ],
          default => "puppet:///${vhost_source}",
        }
        File["${name}.conf"]{
          source => $real_vhost_source,
        }
      }
      default: {
        File["${name}.conf"]{
          content => $content,
        }
      }
    }
  }
  if ($htpasswd_file != 'absent') and ($htpasswd_file != 'nodeploy') {
    $real_htpasswd_path = $htpasswd_path ? {
      'absent' => "/var/www/htpasswds/${name}",
      default  => $htpasswd_path,
    }
    file{$real_htpasswd_path:
      ensure => $ensure,
    }
    if ($ensure != 'absent') {
      File[$real_htpasswd_path]{
        source  => [ "puppet:///modules/site_apache/htpasswds/${::fqdn}/${name}",
                    "puppet:///modules/site_apache/htpasswds/${apache::cluster_node}/${name}",
                    "puppet:///modules/site_apache/htpasswds/${name}" ],
        owner   => root,
        group   => 0,
        mode    => '0644',
      }
    }
  }
}

