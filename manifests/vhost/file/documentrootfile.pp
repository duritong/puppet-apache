define apache::vhost::file::documentrootfile(
      $documentroot,
      $filename,
      $thedomain,
      $owner='root',
      $group='0',
      $mode=440
){
    file{"$documentroot/$filename":
        source  => [ "puppet://$server/files/apache/vhost_varieties/$fqdn/$thedomain/$filename",
                    "puppet://$server/files/apache/vhost_varieties/$apache_cluster_node/$thedomain/$filename",
                    "puppet://$server/files/apache/vhost_varieties/$operatingsystem.$lsbdistcodename/$thedomain/$filename",
                    "puppet://$server/files/apache/vhost_varieties/$operatingsystem/$thedomain/$filename",
                    "puppet://$server/files/apache/vhost_varieties/$thedomain/$filename",
                    "puppet://$server/apache/vhost_varieties/$thedomain/$filename",
                    "puppet://$server/apache/vhost_varieties/$operatingsystem.$lsbdistcodename/$thedomain/$filename",
                    "puppet://$server/apache/vhost_varieties/$operatingsystem/$thedomain/$filename",
                    "puppet://$server/apache/vhost_varieties/$thedomain/$filename"
                   ],
        ensure  => file,
        require => Apache::Vhost::Webdir["$thedomain"],
        owner => $owner, group => $group, mode => $mode;
    }
}

