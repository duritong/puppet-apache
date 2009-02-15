define apache::file::rw() {
    file{$name:
      mode => 660,
      recurse => true
    }
}

define apache::dir::rw(
    $uid = 'absent',
    $gid = 'uid'
){
    file{$name:
	ensure => directory,
        mode => 0770
    }
    selinux::dir::rw{$name:}
}

