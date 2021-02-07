# mod_usertrack module
class apache::module::usertrack {
  if versioncmp($facts['os']['release']['major'],'6') > 0 {
    file_line { 'enable_usertrack_module':
      line    => 'LoadModule usertrack_module modules/mod_usertrack.so',
      match   => 'usertrack_module modules/mod_usertrack.so',
      path    => '/etc/httpd/conf.modules.d/00-base.conf',
      require => Package['apache'],
      notify  => Service['apache'],
    }
  }
}
