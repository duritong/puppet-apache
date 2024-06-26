# run_mode: controls in which mode the vhost should be run, there are different setups
#           possible:
#   - normal: (*default*) run vhost with the current active worker (default: prefork) don't
#             setup anything special
#   - fcgid run vhost with the fcgid module and suexec
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
define apache::vhost::php::standard (
  $ensure                           = present,
  $configuration                    = {},
  $domain                           = 'absent',
  $domainalias                      = 'absent',
  $server_admin                     = 'absent',
  $logmode                          = 'default',
  $logpath                          = 'absent',
  $logprefix                        = undef,
  $path                             = 'absent',
  $manage_webdir                    = true,
  $path_is_webdir                   = false,
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
  $use_mod_macro                    = false,
  $mod_security                     = false,
  $mod_security_relevantonly        = true,
  $mod_security_rules_to_disable    = [],
  $mod_security_additional_options  = 'absent',
  $ssl_mode                         = false,
  $vhost_mode                       = 'template',
  $template_partial                 = 'apache/vhosts/php/partial.erb',
  $vhost_source                     = 'absent',
  $vhost_destination                = 'absent',
  $htpasswd_file                    = 'absent',
  $htpasswd_path                    = 'absent',
) {
  if $manage_webdir {
    # create webdir
    apache::vhost::webdir { $name:
      ensure             => $ensure,
      path               => $path,
      owner              => $owner,
      group              => $group,
      run_mode           => $run_mode,
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
    include apache::defaultphpdirs
    $php_sysroot = "${apache::defaultphpdirs::dir}/${name}"
    if 'fpm_writable_dirs' in $configuration {
      $fpm_writable_dirs = $configuration['fpm_writable_dirs'] + [$php_sysroot]
    } else {
      $fpm_writable_dirs = [$php_sysroot]
    }
  } else {
    $documentroot = "${real_path}/www"
    $php_sysroot = "${real_path}/tmp"
    if 'fpm_writable_dirs' in $configuration {
      $fpm_writable_dirs = $configuration['fpm_writable_dirs']
    } else {
      $fpm_writable_dirs = []
    }
  }
  $logdir = $logpath ? {
    'absent' => "${real_path}/logs",
    default  => $logpath
  }

  if $facts['os']['family'] == 'RedHat' {
    $lib_dirs = ['/usr/share/php/','/usr/share/pear/']
    if $php_installation == 'system' {
      include php
      $sys_libs_tmp = $lib_dirs
      $php_inst_class = undef
    } else {
      $php_inst_class = regsubst($php_installation,'^scl','php')
      require "::php::scl::${php_inst_class}"
      $php_basedir = getvar("php::scl::${php_inst_class}::basedir")
      $php_etcdir = getvar("php::scl::${php_inst_class}::etcdir")
      $sys_libs_tmp = prefix($lib_dirs,"${php_basedir}/root")
    }
    # add an empty element, so get an extra :
    $sys_libs = $sys_libs_tmp + ''
  } else {
    $sys_libs = []
  }

  if $logmode != 'nologs' {
    $php_error_log = "${logdir}/php_error_log"
  } else {
    $php_error_log = undef
  }

  if !('default_charset' in $php_settings) and ($default_charset != 'absent') {
    $std_php_settings_default_charset =  $default_charset ? {
      'On'    => 'iso-8859-1',
      default => $default_charset
    }
  } else {
    $std_php_settings_default_charset = undef
  }

  apache::vhost::phpdirs { $name:
    ensure             => $ensure,
    path               => $php_sysroot,
    documentroot_owner => $documentroot_owner,
    documentroot_group => $documentroot_group,
    documentroot_mode  => $documentroot_mode,
    run_mode           => $run_mode,
    run_uid            => $run_uid,
  }

  $sys_libs_str = join($sys_libs,':')
  if ('additional_open_basedir' in $php_options) {
    $the_open_basedir = "${sys_libs_str}${documentroot}:${real_path}/data:${php_sysroot}:${php_options[additional_open_basedir]}"
  } else {
    $the_open_basedir = "${sys_libs_str}${documentroot}:${real_path}/data:${php_sysroot}"
  }

  # safe mode is (finally) gone on most systems
  if $php_installation == 'system' and $facts['os']['name'] == 'CentOS' and versioncmp($facts['os']['release']['major'],'7') < 0 {
    if ('safe_mode_exec_dir' in $php_settings) {
      $php_safe_mode_exec_dir = $php_settings['safe_mode_exec_dir']
    } else {
      $php_safe_mode_exec_dir =  $path ? {
        'absent' => "/var/www/vhosts/${name}/bin",
        default   => "${path}/bin",
      }
    }
    file { $php_safe_mode_exec_dir:
      recurse => true,
      force   => true,
      purge   => true,
    }
    if ('safe_mode_exec_bins' in $php_options) {
      $std_php_settings_safe_mode_exec_dir = $php_safe_mode_exec_dir
      $ensure_exec = $ensure ? {
        'present'  => directory,
        default    => 'absent',
      }
      File[$php_safe_mode_exec_dir] {
        ensure => $ensure_exec,
        owner  => $documentroot_owner,
        group  => $documentroot_group,
        mode   => '0750',
      }
      $php_safe_mode_exec_bins_subst = regsubst($php_options['safe_mode_exec_bins'],'(.+)',"${name}@\\1")
      apache::vhost::php::safe_mode_bin {
        $php_safe_mode_exec_bins_subst:
          ensure => $ensure,
          path   => $php_safe_mode_exec_dir;
      }
    } else {
      $std_php_settings_safe_mode_exec_dir = undef
      File[$php_safe_mode_exec_dir] {
        ensure => absent,
      }
    }

    $safe_mode = 'On'
    if $run_mode == 'fcgid' {
      $safe_mode_gid = 'On'
    } else {
      $safe_mode_gid = undef
    }
  } else {
    $safe_mode = undef
    $safe_mode_gid = undef
    $std_php_settings_safe_mode_exec_dir = undef
  }

  $std_php_settings = {
    engine               => 'On',
    upload_tmp_dir       => "${php_sysroot}/uploads",
    'session.save_path'  => "${php_sysroot}/sessions",
    error_log            => $php_error_log,
    safe_mode            => $safe_mode,
    safe_mode_gid        => $safe_mode_gid,
    safe_mode_exec_dir   => $std_php_settings_safe_mode_exec_dir,
    default_charset      => $std_php_settings_default_charset,
    open_basedir         => $the_open_basedir,
    'apc.mmap_file_mask' => "${php_sysroot}/apc.XXXXXX",
  }

  if ($php_installation =~ /^scl/) and ($php_installation !~ /^scl5/) {
    $php_inst_settings = {
      'sp.configuration_file' => "${php_etcdir}/php.d/snuffleupagus-*.rules,${php_etcdir}/snuffleupagus.d/base.rules,${php_etcdir}/snuffleupagus.d/${name}.rules",
    }
    if $ensure != 'absent' {
      $sp_global_secret_key = trocla("php_${name}_sp.global.secret_key",'plain',{ 'length' => 64,'charset' => 'alphanumeric' })
      $def_rules = { '005-sp.global.secret_key' => "sp.global.secret_key(\"${sp_global_secret_key}\");" }
      php::snuffleupagus {
        $name:
          etcdir       => $php_etcdir,
          rules        => $def_rules + pick($php_options['snuffleupagus_rules'],{}),
          ignore_rules => pick($php_options['snuffleupagus_ignore_rules'],[]),
          group        => $run_gid,
          version      => regsubst($php_installation,'^scl',''),
      }
    }
  } else {
    $php_inst_settings = {}
  }

  $real_php_settings = $php_inst_settings + $std_php_settings + $php_settings

  if $ensure != 'absent' {
    case $run_mode {
      'fcgid': {
        include mod_fcgid
        include php::mod_fcgid
        include apache::include::mod_fcgid

        mod_fcgid::starter { $name:
          tmp_dir          => "${php_sysroot}/tmp",
          cgi_type         => 'php',
          cgi_type_options => $real_php_settings,
          additional_envs  => $php_options['additional_envs'],
          owner            => $run_uid,
          group            => $run_gid,
          notify           => Service['apache'],
        }
        if $php_installation =~ /^scl/ {
          Mod_fcgid::Starter[$name] {
            binary          => "${php_basedir}/root/usr/bin/php-cgi",
            additional_cmds => "source ${php_basedir}/enable",
            rc              => $php_etcdir,
          }
        }
      }
    }
  }

  if $run_mode == 'fpm' {
    if $logdir == '/var/log/httpd' {
      $fpm_logdir = "/var/log/fpm-${name}"
      file {
        $fpm_logdir:
          owner   => $run_uid,
          group   => $run_gid,
          mode    => '0640',
          seltype => 'httpd_log_t',
          before  => Php::Fpm[$name],
      }
      if $ensure == 'present' {
        File[$fpm_logdir] {
          ensure => directory
        }
      } else {
        File[$fpm_logdir] {
          ensure => 'absent'
        }
      }
      $fpm_php_settings = $real_php_settings + { error_log => "${fpm_logdir}/php_error_log" }
    } else {
      $fpm_logdir = $logdir
      $fpm_php_settings = $real_php_settings
    }
    if 'fpm_settings' in $configuration {
      $fpm_settings = $configuration['fpm_settings']
    } else {
      $fpm_settings = {}
    }
    php::fpm {
      $name:
        ensure          => $ensure,
        php_inst_class  => $php_inst_class,
        workdir         => $real_path,
        logdir          => $fpm_logdir,
        tmpdir          => "${php_sysroot}/tmp",
        run_user        => $run_uid,
        run_group       => $run_gid,
        additional_envs => $php_options['additional_envs'],
        fpm_settings    => $fpm_settings,
        php_settings    => $fpm_php_settings,
        writable_dirs   => $fpm_writable_dirs,
    }
  }

  logrotate::rule { "php_${name}": }
  if $real_php_settings['error_log'] and ($ensure != 'absent') and !($logdir in ['/var/log/httpd','/var/log/apache2']) {
    if defined('$fpm_logdir') and $fpm_logdir =~ /^\/var\/log\/fpm-/ {
      $logrotate_path = [ $real_php_settings['error_log'], "${fpm_logdir}/*log" ]
    } else {
      $logrotate_path = $real_php_settings['error_log']
    }
    if $run_mode == 'normal' {
      $logrotate_user = 'apache'
      $logrotate_group = 'apache'
    } else {
      $logrotate_user = $run_uid
      $logrotate_group = $run_gid
    }
    Logrotate::Rule["php_${name}"]{
      ensure       => $ensure,
      path         => $logrotate_path,
      compress     => true,
      copytruncate => true,
      dateext      => true,
      create       => true,
      rotate_every => 'day',
      missingok    => true,
      ifempty      => false,
      rotate       => 7,
      create_mode  => '0640',
      create_owner => $logrotate_user,
      create_group => $logrotate_group,
      su           => true,
      su_user      => $logrotate_user,
      su_group     => $logrotate_group,
    }
    if $manage_webdir {
      File[$logdir] -> Logrotate::Rule["php_${name}"]
    }
  } else {
    Logrotate::Rule["php_${name}"]{
      ensure => absent,
    }
  }

  # create vhost configuration file
  apache::vhost { $name:
    ensure                          => $ensure,
    configuration                   => $configuration,
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
    run_mode                        => $run_mode,
    run_uid                         => $run_uid,
    run_gid                         => $run_gid,
    allow_override                  => $allow_override,
    do_includes                     => $do_includes,
    options                         => $options,
    additional_options              => $additional_options,
    default_charset                 => $default_charset,
    php_settings                    => $real_php_settings,
    php_options                     => $php_options,
    ssl_mode                        => $ssl_mode,
    htpasswd_file                   => $htpasswd_file,
    htpasswd_path                   => $htpasswd_path,
    mod_security                    => $mod_security,
    mod_security_relevantonly       => $mod_security_relevantonly,
    mod_security_rules_to_disable   => $mod_security_rules_to_disable,
    mod_security_additional_options => $mod_security_additional_options,
    use_mod_macro                   => $use_mod_macro,
    passing_extension               => 'php',
  }
}
