define apache::file::rw(
    $owner = root,
    $group = 0,
    $mode = 0660
) {
    apache::file{$name:
        owner => $owner,
        group => $group,
        mode => $mode,
    }
}
define apache::file::readonly(
    $owner = root,
    $group = 0,
    $mode = 0640
) {
    apache::file{$name:
        owner => $owner,
        group => $group,
        mode => $mode,
    }
}
define apache::file(
    $owner = root,
    $group = 0,
    $mode = 0640
) {
    file{$name:
        recurse => true,
        backup => false,
        checksum => mtime,
        owner => $owner, group => $group, mode => $mode;
    }
}
