# a managed directory of a vhost
define apache::vhost::managed_directory(
  $owner,
  $group,
  $mode    = '0660',
) {
  file{$name:
    ensure   => directory,
    backup   => false,
    checksum => undef,
    owner    => $owner,
    group    => $group,
    mode     => $mode;
  }
  if str2bool($::selinux) {
    $seltype = $::operatingsystemmajrelease ? {
      '5'     => 'httpd_sys_script_rw_t',
      default => 'httpd_sys_rw_content_t'
    }
    File[$name]{
      seltype => $seltype,
    }
  }
}
