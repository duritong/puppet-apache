# ToDo: This should be rewritten as native type
define apache::htpasswd_user(
  $password,
  $ensure             = present,
  $site               = 'absent',
  $username           = 'absent',
  $password_iscrypted = false,
  $ensure             = 'present',
  $path               = 'absent'
){
  case $username {
    'absent': { $real_username = $name }
    default: { $real_username = $username }
  }
  case $site {
    'absent': { $real_site = $name }
    default: { $real_site = $site }
  }
  if $password_iscrypted {
    $real_password = $password
  } else {
    $real_password = htpasswd_sha1($password)
  }

  $real_path = $path ? {
    'absent' => "/var/www/htpasswds/${real_site}",
    default  => $path
  }
  file_line{"htpasswd_for_${real_site}":
    ensure => $ensure,
    path   => $real_path,
    line   => "${username}:${real_password}",
  }
}
