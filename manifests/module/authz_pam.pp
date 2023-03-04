# install the authz pam module
class apache::module::authz_pam {

  package { 'mod_authnz_pam':
    ensure  => present,
    require => Package['apache'],
  } -> concat {'/etc/httpd/conf.modules.d/pam-httpd-allow-users':
    owner => root,
    group => apache,
    mode  => '0640',
  } -> file { '/etc/pam.d/httpd':
    content => epp('apache/authz-pam/httpd-service.epp',{}),
    owner   => root,
    group   => apache,
    mode    => '0640',
  } -> selboolean { 'httpd_mod_auth_pam':
    value      => on,
    persistent => true,
    before     => Service['apache'];
  } -> file { '/etc/httpd/conf.modules.d/55-authnz_pam.conf':
    content => "\nLoadModule authnz_pam_module modules/mod_authnz_pam.so\n\n",
    owner   => root,
    group   => 0,
    mode    => '0644',
    notify  => Service['apache'],
  }

  concat::fragment { 'httpd_pam_allow_header':
    target  => '/etc/httpd/conf.modules.d/pam-httpd-allow-users',
    content => "# Following users are allowed for PAM authentication through httpd\n",
    order   => '01';
  }
}
