# install the authz pam module
class apache::module::authz_pam {

  package { 'mod_authnz_pam':
    ensure  => present,
    require => Package['apache'],
    notify  => Service['apache'],
  } -> concat {'/etc/httpd/conf.d/pam-httpd-allow-users':
    owner => root,
    group => apache,
    mode  => '0640',
  } -> file { '/etc/pam.d/httpd':
    content => epp('apache/authz-pam/httpd-pam.epp',{}),
    owner   => root,
    group   => apache,
    mode    => '0640',
  } -> selboolean { 'httpd_mod_auth_pam':
    value      => on,
    persistent => true,
    before     => Service['apache'];
  }

  concat::fragment { 'httpd_pam_allow_header':
    target  => '/etc/httpd/conf.d/pam-httpd-allow-users',
    content => "# Following users are allowed for PAM authentication through httpd\n",
    order   => '01';
  }
}
