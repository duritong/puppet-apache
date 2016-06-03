# a file that is writable by apache
define apache::file::rw(
  $owner  = root,
  $group  = 0,
  $mode   = '0660',
) {
  apache::file{$name:
    owner => $owner,
    group => $group,
    mode  => $mode,
  }
  if str2bool($::selinux) {
    $seltype_rw = $::operatingsystemmajrelease ? {
      '5'     => 'httpd_sys_script_rw_t',
      default => 'httpd_sys_rw_content_t'
    }
    Apache::File[$name]{
      seltype => $seltype_rw,
    }
  }
}

