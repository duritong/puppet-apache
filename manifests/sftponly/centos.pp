# manage sftponly group and apache
# user for access
class apache::sftponly::centos {
  require user::groups::sftponly
  augeas{"add_apache_to_group_sftponly":
    context => "/files/etc/group",
    changes => [ "ins user after sftponly/user[last()]",
      "set sftponly/user[last()] apache" ],
    onlyif  => "match sftponly/*[../user='apache'] size == 0",
    require => [ Package['apache'], Group['sftponly'] ],
    notify  =>  Service['apache'],
  }
}
