# manage auth_mellon basics
class apache::module::auth_mellon {
  package{'mod_auth_mellon':
    ensure  => installed,
    require => Package['apache'],
  } -> file{'/etc/httpd/mellon':
    ensure  => directory,
    owner   => root,
    group   => apache,
    mode    => '0640',
    purge   => true,
    recurse => true,
    force   => true,
    notify  => Service['apache'],
  }
}
