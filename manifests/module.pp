define apache::module (
  $ensure = present, $source = '',
  $destination = '', $module = $name, $package_name = '' ) 
{

  case $operatingsystem {
    'centos': {
      apache::centos::module { "$module":
        ensure => $ensure, source => $source,
        destination => $destination
      }
    }
    'gentoo': {
      apache::gentoo::module { "$module":
        ensure => $ensure, source => $source,
        destination => $destination
      }
    }
    'debian','ubuntu': {
      apache::debian::module { "$module":
        ensure => $ensure, package_name => $package_name
      }
    }
    default: {
      err('Your operating system does not have a module deployment mechanism defined')
    }
  }
}
