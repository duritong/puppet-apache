# manage apache monitoring things
class apache::munin {
  if $::osfamily == 'Debian' {
    include perl::extensions::libwww
  }

  if $::operatingsystem == 'CentOS' and versioncmp($::operatingsystemmajrelease,'6') > 0 {
    $seltype = 'services_munin_plugin_exec_t'
  } else {
    $seltype = 'munin_services_plugin_exec_t'
  }
  munin::plugin{ [ 'apache_accesses', 'apache_processes', 'apache_volume' ]: }
  munin::plugin::deploy { 'apache_activity':
    source  => 'apache/munin/apache_activity',
    seltype => $seltype,
  }
}
