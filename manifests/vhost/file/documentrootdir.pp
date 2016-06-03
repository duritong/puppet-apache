# manage a documentrootdir
define apache::vhost::file::documentrootdir(
  $documentroot,
  $filename,
  $thedomain,
  $owner         = 'root',
  $group         = '0',
  $mode          = '0440',
){
  $path = "${documentroot}/${filename}"
  file{
    $path:
      ensure  => directory,
      require => Apache::Vhost::Webdir[$thedomain],
      owner   => $owner,
      group   => $group,
      mode    => $mode;
  }
}

