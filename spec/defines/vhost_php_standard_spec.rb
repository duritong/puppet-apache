require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::php::standard', :type => 'define' do
  let(:title){ 'example.com' }
  let(:default_facts){
    {
      :fqdn => 'apache.example.com',
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '7',
    }
  }
  let(:facts){ default_facts }
  describe 'with standard' do
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to_not contain_class('mod_fcgid') }
    it { is_expected.to_not contain_class('php::mod_fcgid') }
    it { is_expected.to_not contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to_not contain_class('php::extensions::smarty') }
    it { is_expected.to contain_class('php') }
    it { is_expected.to_not contain_mod_fcgid__starter('example.com') }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :php_upload_tmp_dir     => '/var/www/upload_tmp_dir/example.com',
      :php_session_save_path  => '/var/www/session.save_path/example.com',
    )}
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost('example.com').with(
      :template_partial  => 'apache/vhosts/php/partial.erb',
      :passing_extension => 'php'
    )}

    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with(
      :content => /create 640 apache apache/,
      :owner   => 'root',
      :group   => 0,
      :mode    => '0644',
      :require => 'File[/var/www/vhosts/example.com/logs]',
    )}
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_content(/\/var\/www\/vhosts\/example.com\/logs\/php_error_log/) }
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_content(/su apache apache/) }

    it { is_expected.to have_apache__vhost__php__safe_mode_bin_resource_count(0) }
    # go deeper in the catalog and test the produced template
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/
  DirectoryIndex index.htm index.html index.php


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None

    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com
    php_admin_value session.save_path /var/www/session.save_path/example.com
    php_admin_value upload_tmp_dir /var/www/upload_tmp_dir/example.com


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'on EL6' do
    let(:facts){
      default_facts.merge(:operatingsystemmajrelease => '6')
    }
    # go deeper in the catalog and test the produced template for the main difference
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(/php_admin_flag safe_mode on/) }
  end
  describe 'with standard and params' do
    let(:facts){
      default_facts.merge(:operatingsystemmajrelease => '6')
    }
    let(:params) {
      {
        :php_settings => {
          'safe_mode' => 'Off',
        }
      }
    }
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with(
      :content => /create 640 apache apache/,
      :owner   => 'root',
      :group   => 0,
      :mode    => '0644',
      :require => 'File[/var/www/vhosts/example.com/logs]',
    )}
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_content(/\/var\/www\/vhosts\/example.com\/logs\/php_error_log/) }
    it { is_expected.to_not contain_file('/etc/logrotate.d/php_example.com').with_content(/su apache apache/) }

    # go deeper in the catalog and test the produced template
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/
  DirectoryIndex index.htm index.html index.php


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None

    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com
    php_admin_flag safe_mode off
    php_admin_value session.save_path /var/www/session.save_path/example.com
    php_admin_value upload_tmp_dir /var/www/upload_tmp_dir/example.com


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with mod_fcgid' do
    let(:params){
      {
        :run_mode => 'fcgid',
        :run_uid  => 'foo',
        :run_gid  => 'bar',
      }
    }
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to_not contain_class('php::extensions::smarty') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => false,
      :cgi_type         => 'php',
      :cgi_type_options => {
        "engine"            =>"On",
        "upload_tmp_dir"    =>"/var/www/upload_tmp_dir/example.com",
        "session.save_path" =>"/var/www/session.save_path/example.com",
        "error_log"         =>"/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"         =>:undef,
        "safe_mode_gid"     =>:undef,
        "safe_mode_exec_dir"=>:undef,
        "default_charset"   =>:undef,
        "open_basedir"      =>"/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com"
      },
      :owner            => 'foo',
      :group            => 'bar',
      :notify           => 'Service[apache]',
    ) }

    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with(
      :content => /create 640 foo bar/,
      :owner   => 'root',
      :group   => 0,
      :mode    => '0644',
      :require => 'File[/var/www/vhosts/example.com/logs]',
    )}
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_content(/\/var\/www\/vhosts\/example.com\/logs\/php_error_log/) }
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_content(/su foo bar/) }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :php_upload_tmp_dir     => '/var/www/upload_tmp_dir/example.com',
      :php_session_save_path  => '/var/www/session.save_path/example.com',
    )}
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost('example.com').with(
      :template_partial  => 'apache/vhosts/php/partial.erb',
      :passing_extension => 'php'
    )}

    it { is_expected.to have_apache__vhost__php__safe_mode_bin_resource_count(0) }
    # go deeper in the catalog and test the produced template
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/
  DirectoryIndex index.htm index.html index.php


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <IfModule mod_fcgid.c>
    SuexecUserGroup foo bar
    FcgidMaxRequestsPerProcess 5000
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with mod_fcgid scl 5.4' do
    let(:pre_condition){ 'include yum::prerequisites' }
    let(:params){
      {
        :run_mode         => 'fcgid',
        :run_uid          => 'foo',
        :run_gid          => 'bar',
        :php_installation => 'scl54',
      }
    }
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to_not contain_class('php::extensions::smarty') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => false,
      :cgi_type         => 'php',
      :cgi_type_options => {
        "engine"            =>"On",
        "upload_tmp_dir"    =>"/var/www/upload_tmp_dir/example.com",
        "session.save_path" =>"/var/www/session.save_path/example.com",
        "error_log"         =>"/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"         =>:undef,
        "safe_mode_gid"     =>:undef,
        "safe_mode_exec_dir"=>:undef,
        "default_charset"   =>:undef,
        "open_basedir"      =>"/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com"
      },
      :binary           => '/opt/rh/php54/root/usr/bin/php-cgi',
      :additional_cmds  => 'source /opt/rh/php54/enable',
      :rc               => '/opt/rh/php54/root/etc',
      :owner            => 'foo',
      :group            => 'bar',
      :notify           => 'Service[apache]',
    ) }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :php_upload_tmp_dir     => '/var/www/upload_tmp_dir/example.com',
      :php_session_save_path  => '/var/www/session.save_path/example.com',
    )}
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost('example.com').with(
      :template_partial  => 'apache/vhosts/php/partial.erb',
      :passing_extension => 'php'
    )}

    it { is_expected.to have_apache__vhost__php__safe_mode_bin_resource_count(0) }
    # go deeper in the catalog and test the produced template
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/
  DirectoryIndex index.htm index.html index.php


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <IfModule mod_fcgid.c>
    SuexecUserGroup foo bar
    FcgidMaxRequestsPerProcess 5000
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with mod_fcgid with scl55' do
    let(:pre_condition){ 'include yum::prerequisites' }
    let(:params){
      {
        :run_mode         => 'fcgid',
        :run_uid          => 'foo',
        :run_gid          => 'bar',
        :php_installation => 'scl55',
      }
    }
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to contain_class('php::scl::php55') }
    it { is_expected.to_not contain_class('php::extensions::smarty') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => false,
      :cgi_type         => 'php',
      :cgi_type_options => {
        "engine"            =>"On",
        "upload_tmp_dir"    =>"/var/www/upload_tmp_dir/example.com",
        "session.save_path" =>"/var/www/session.save_path/example.com",
        "error_log"         =>"/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"         =>:undef,
        "safe_mode_gid"     =>:undef,
        "safe_mode_exec_dir"=>:undef,
        "default_charset"   =>:undef,
        "open_basedir"      =>"/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com"
      },
      :binary           => '/opt/rh/php55/root/usr/bin/php-cgi',
      :additional_cmds  => 'source /opt/rh/php55/enable',
      :rc               => '/opt/rh/php55/root/etc',
      :owner            => 'foo',
      :group            => 'bar',
      :notify           => 'Service[apache]',
    ) }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :php_upload_tmp_dir     => '/var/www/upload_tmp_dir/example.com',
      :php_session_save_path  => '/var/www/session.save_path/example.com',
    )}
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost('example.com').with(
      :template_partial  => 'apache/vhosts/php/partial.erb',
      :passing_extension => 'php'
    )}

    it { is_expected.to have_apache__vhost__php__safe_mode_bin_resource_count(0) }
    # go deeper in the catalog and test the produced template
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/
  DirectoryIndex index.htm index.html index.php


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <IfModule mod_fcgid.c>
    SuexecUserGroup foo bar
    FcgidMaxRequestsPerProcess 5000
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with mod_fcgid and params' do
    let(:facts){default_facts.merge(:operatingsystemmajrelease => '6')}
    let(:params){
      {
        :run_mode     => 'fcgid',
        :run_uid      => 'foo',
        :run_gid      => 'bar',
        :logmode      => 'nologs',
        :php_options  => {
          'smarty'              => true,
          'pear'                => true,
          'safe_mode_exec_bins' => ['/usr/bin/cat'],
        }
      }
    }
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to contain_class('php::extensions::smarty') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => false,
      :cgi_type         => 'php',
      :cgi_type_options => {
        "engine"            =>"On",
        "upload_tmp_dir"    =>"/var/www/upload_tmp_dir/example.com",
        "session.save_path" =>"/var/www/session.save_path/example.com",
        "error_log"         =>:undef,
        "safe_mode"         =>"On",
        "safe_mode_gid"     =>"On",
        "safe_mode_exec_dir"=>"/var/www/vhosts/example.com/bin",
        "default_charset"   =>:undef,
        "open_basedir"      =>"/usr/share/php/Smarty/:/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com"
      },
      :owner            => 'foo',
      :group            => 'bar',
      :notify           => 'Service[apache]',
    ) }
    # with no log it is_expected.to be absent
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_ensure('absent') }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :php_upload_tmp_dir     => '/var/www/upload_tmp_dir/example.com',
      :php_session_save_path  => '/var/www/session.save_path/example.com',
    )}
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost('example.com').with(
      :template_partial  => 'apache/vhosts/php/partial.erb',
      :passing_extension => 'php'
    )}

    it { is_expected.to have_apache__vhost__php__safe_mode_bin_resource_count(1) }
    it { is_expected.to contain_apache__vhost__php__safe_mode_bin('example.com@/usr/bin/cat').with(
      :ensure => 'present',
      :path   => '/var/www/vhosts/example.com/bin',
    )}
    it { is_expected.to contain_file('/var/www/vhosts/example.com/bin').with(
      :ensure  => 'directory',
      :owner   => 'apache',
      :group   => '0',
      :recurse => true,
      :force   => true,
      :purge   => true,
    )}
    # go deeper in the catalog and test the produced template
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/
  DirectoryIndex index.htm index.html index.php


  ErrorLog /dev/null
  CustomLog /dev/null %%



  <IfModule mod_fcgid.c>
    SuexecUserGroup foo bar
    FcgidMaxRequestsPerProcess 5000
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with absent' do
    let(:facts){default_facts.merge(:operatingsystemmajrelease => '6')}
    let(:params){
      {
        :ensure       => 'absent',
        :run_mode     => 'fcgid',
        :run_uid      => 'foo',
        :run_gid      => 'bar',
        :logmode      => 'nologs',
        :php_options  => {
          'smarty'              => true,
          'pear'                => true,
          'safe_mode_exec_bins' => ['/usr/bin/cat'],
        }
      }
    }
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__webdir('example.com').with_ensure('absent') }
    it { is_expected.to_not contain_class('mod_fcgid') }
    it { is_expected.to_not contain_class('php::mod_fcgid') }
    it { is_expected.to_not contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to contain_class('php::extensions::smarty') }
    it { is_expected.to_not contain_mod_fcgid__starter('example.com') }
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_ensure('absent') }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with_ensure('absent') }
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost('example.com').with_ensure('absent') }

    it { is_expected.to have_apache__vhost__php__safe_mode_bin_resource_count(1) }
    it { is_expected.to contain_apache__vhost__php__safe_mode_bin('example.com@/usr/bin/cat').with_ensure('absent') }
    it { is_expected.to contain_file('/var/www/vhosts/example.com/bin').with_ensure('absent') }
    it { is_expected.to contain_apache__vhost__file('example.com').with_ensure('absent') }
  end
end
