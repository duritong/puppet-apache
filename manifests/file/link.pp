define apache::file::link(
    $target = 'absent'
) {
    if ($target != 'absent') { 
      file { "$name":
            ensure => link,
            target => "${target}"
      }
    }
}


