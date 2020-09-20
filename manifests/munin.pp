# manage apache monitoring things
class apache::munin(
  $pwd,
) {
  if $facts['osfamily'] == 'Debian' {
    include perl::extensions::libwww
  }

  if $facts['operatingsystem'] == 'CentOS' and versioncmp($facts['operatingsystemmajrelease'],'6') > 0 {
    $seltype = 'services_munin_plugin_exec_t'
  } else {
    $seltype = 'munin_services_plugin_exec_t'
  }

  $config_str = "env.url   http://munin:${pwd}@127.0.0.3:%d/server-status?auto\nenv.ports 80"
  munin::plugin{
    [ 'apache_accesses', 'apache_processes', 'apache_volume' ]:
      config => $config_str;
  }
  munin::plugin::deploy { 'apache_activity':
    source  => 'apache/munin/apache_activity',
    config  => $config_str,
    seltype => $seltype;
  }
}
