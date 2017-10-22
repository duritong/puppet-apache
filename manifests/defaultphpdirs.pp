# setup some directories for php
class apache::defaultphpdirs {
  $dir = '/var/www/php_tmp'
  file{
    $dir:
      ensure  => directory,
      require => Package['apache'],
      owner   => root,
      group   => 0,
      mode    => '0755';
  }

  if str2bool($::selinux) {
    $seltype_rw = $::operatingsystemmajrelease ? {
      '5'     => 'httpd_sys_script_rw_t',
      default => 'httpd_sys_rw_content_t'
    }
    selinux::fcontext{
      "${dir}/.+(/.*)?":
        before => Package['apache'],
        setype => $seltype_rw,
    }
  }
}
