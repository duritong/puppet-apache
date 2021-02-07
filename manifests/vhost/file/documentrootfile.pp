# place a file in the documentroot
define apache::vhost::file::documentrootfile (
  $documentroot,
  $filename,
  $thedomain,
  $owner        = 'root',
  $group        = '0',
  $mode         = '0440',
) {
  include apache
  file { "${documentroot}/${filename}":
    source  => ["puppet:///modules/site_apache/vhost_varieties/${facts['networking']['fqdn']}/${thedomain}/${filename}",
      "puppet:///modules/site_apache/vhost_varieties/${apache::cluster_node}/${thedomain}/${filename}",
      "puppet:///modules/site_apache/vhost_varieties/${facts['os']['name']}.${facts['os']['release']['major']}/${thedomain}/${filename}",
      "puppet:///modules/site_apache/vhost_varieties/${facts['os']['name']}/${thedomain}/${filename}",
      "puppet:///modules/site_apache/vhost_varieties/${thedomain}/${filename}",
      "puppet:///modules/apache/vhost_varieties/${thedomain}/${filename}",
      "puppet:///modules/apache/vhost_varieties/${facts['os']['name']}.${facts['os']['release']['major']}/${thedomain}/${filename}",
      "puppet:///modules/apache/vhost_varieties/${facts['os']['name']}/${thedomain}/${filename}",
      "puppet:///modules/apache/vhost_varieties/${thedomain}/${filename}",
    ],
    require => Apache::Vhost::Webdir[$thedomain],
    owner   => $owner,
    group   => $group,
    mode    => $mode;
  }
}
