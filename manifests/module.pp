define apache::module (
  $ensure       = present,
  $source       = '',
  $destination  = '',
  $module       = '',
  $package_name = 'absent',
  $conf_content = '',
  $conf_source  = '',
){

  $real_module = $module ? {
    ''      => $name,
    default => $module,
  }

  case $operatingsystem {
    'CentOS': {
      apache::centos::module{$real_module:
        ensure      => $ensure,
        source      => $source,
        destination => $destination
      }
    }
    'Debian','Ubuntu':{
      apache::debian::module{$real_module:
        ensure       => $ensure,
        package_name => $package_name,
        conf_content => $conf_content,
        conf_source  => $conf_source,
      }
    }
    default: {
      err('Your operating system does not have a module deployment mechanism defined')
    }
  }
}
