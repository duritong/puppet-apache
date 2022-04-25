# install the openidc module
class apache::module::auth_openidc {
  package { 'mod_auth_openidc':
    ensure  => present,
    require => Package[apache],
    notify  => Service[apache],
  }
}
