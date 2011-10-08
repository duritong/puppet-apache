define apache::vhost::php::safe_mode_bin(
  $ensure = 'present',
  $path
){
  $substr=regsubst($name,'^.*\/','','G')
  $real_path = "$path/$substr"
  file{$real_path:
    ensure => $ensure ? {
      'present' => regsubst($name,'^.*@',''),
      default => absent,
    }
  }
}

