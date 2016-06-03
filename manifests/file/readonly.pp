# manage a simple readonly file
define apache::file::readonly(
  $owner = root,
  $group = 0,
  $mode  = '0640',
) {
  apache::file{$name:
    owner => $owner,
    group => $group,
    mode  => $mode,
  }
  if str2bool($::selinux) {
    Apache::File[$name]{
      seltype => 'httpd_sys_content_t',
    }
  }
}

