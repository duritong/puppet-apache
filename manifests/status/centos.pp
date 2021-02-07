### status config
class apache::status::centos {
  file { '/var/www/htpasswds/munin-status':
    content => "munin:${htpasswd_sha1($apache::status::pwd)}",
    owner   => root,
    group   => apache,
    mode    => '0640',
  } -> apache::config::global { 'status.conf': }
}
