# manage a simple file
define apache::file(
  $owner   = root,
  $group   = 0,
  $mode    = '0640',
  $seltype = undef,
) {
  file{$name:
    backup   => false,
    checksum => undef,
    owner    => $owner,
    group    => $group,
    mode     => $mode;
  }
  if $seltype and str2bool($::selinux) {
    File[$name]{
      seltype => $seltype,
    }
  }
}

