require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::php::standard', :type => 'define' do
  before(:each) do
    Puppet::Parser::Functions.newfunction(:trocla, :type => :rvalue) { |args|
        'expected value'
    }
  end
  let(:title){ 'example.com' }
  let(:default_facts){
    {
      :fqdn => 'apache.example.com',
      :os                         => {
        'family' => 'RedHat',
        :release => {
          :major => '7',
        },
      },
      :selinux                    => true,
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '7',
      :selinux                    => true,
      :path                       => '/usr',
    }
  }
  let(:facts){ default_facts }
  let(:pre_condition){ 'Exec{ path => "/bin" }' }
  describe 'with standard' do
    # only test variables that are tuned
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to_not contain_class('mod_fcgid') }
    it { is_expected.to_not contain_class('php::mod_fcgid') }
    it { is_expected.to_not contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to contain_class('php') }
    it { is_expected.to_not contain_mod_fcgid__starter('example.com') }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :path => '/var/www/vhosts/example.com/tmp',
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
    )}
    it { is_expected.to contain_file('/var/www/vhosts/example.com/logs').with(
      :before => ['Service[apache]','File[/etc/logrotate.d/php_example.com]', ],
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

    php_admin_value apc.mmap_file_mask /var/www/vhosts/example.com/tmp/apc.XXXXXX
    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /usr/share/php/:/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp
    php_admin_value session.save_path /var/www/vhosts/example.com/tmp/sessions
    php_admin_value upload_tmp_dir /var/www/vhosts/example.com/tmp/uploads


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
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
    it { is_expected.to compile.with_all_deps }
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
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with(
      :content => /create 640 apache apache/,
      :owner   => 'root',
      :group   => 0,
      :mode    => '0644',
    )}
    it { is_expected.to contain_file('/var/www/vhosts/example.com/logs').with(
      :before => ['Service[apache]','File[/etc/logrotate.d/php_example.com]', ],
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

    php_admin_value apc.mmap_file_mask /var/www/vhosts/example.com/tmp/apc.XXXXXX
    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /usr/share/php/:/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp
    php_admin_flag safe_mode off
    php_admin_value session.save_path /var/www/vhosts/example.com/tmp/sessions
    php_admin_value upload_tmp_dir /var/www/vhosts/example.com/tmp/uploads


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
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
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => '/var/www/vhosts/example.com/tmp/tmp',
      :cgi_type         => 'php',
      :cgi_type_options => {
        "apc.mmap_file_mask" => "/var/www/vhosts/example.com/tmp/apc.XXXXXX",
        "engine"             => "On",
        "upload_tmp_dir"     => "/var/www/vhosts/example.com/tmp/uploads",
        "session.save_path"  => "/var/www/vhosts/example.com/tmp/sessions",
        "error_log"          => "/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"          => nil,
        "safe_mode_gid"      => nil,
        "safe_mode_exec_dir" => nil,
        "default_charset"    => nil,
        "open_basedir"       => "/usr/share/php/:/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp",
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
    )}
    it { is_expected.to contain_file('/var/www/vhosts/example.com/logs').with(
      :before => ['Service[apache]','File[/etc/logrotate.d/php_example.com]', ],
    )}
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_content(/\/var\/www\/vhosts\/example.com\/logs\/php_error_log/) }
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_content(/su foo bar/) }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :path => '/var/www/vhosts/example.com/tmp',
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
    FcgidMaxRequestsPerProcess 4990
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
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
    let(:pre_condition){ 'Exec{ path => "/bin" }
                         include yum::prerequisites' }
    let(:params){
      {
        :run_mode         => 'fcgid',
        :run_uid          => 'foo',
        :run_gid          => 'bar',
        :php_installation => 'scl54',
      }
    }
    # only test variables that are tuned
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => "/var/www/vhosts/example.com/tmp/tmp",
      :cgi_type         => 'php',
      :cgi_type_options => {
        "apc.mmap_file_mask" => "/var/www/vhosts/example.com/tmp/apc.XXXXXX",
        "engine"             => "On",
        "upload_tmp_dir"     => "/var/www/vhosts/example.com/tmp/uploads",
        "session.save_path"  => "/var/www/vhosts/example.com/tmp/sessions",
        "error_log"          => "/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"          => nil,
        "safe_mode_gid"      => nil,
        "safe_mode_exec_dir" => nil,
        "default_charset"    => nil,
        "open_basedir"       => "/opt/rh/php54/root/usr/share/php/:/opt/rh/php54/root/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp"
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
      :path => '/var/www/vhosts/example.com/tmp',
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
    FcgidMaxRequestsPerProcess 4990
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
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
    let(:pre_condition){ 'Exec{ path => "/bin" }
                         include yum::prerequisites' }
    let(:params){
      {
        :run_mode         => 'fcgid',
        :run_uid          => 'foo',
        :run_gid          => 'bar',
        :php_installation => 'scl55',
      }
    }
    # only test variables that are tuned
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to contain_class('php::scl::php55') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => '/var/www/vhosts/example.com/tmp/tmp',
      :cgi_type         => 'php',
      :cgi_type_options => {
        "apc.mmap_file_mask" => "/var/www/vhosts/example.com/tmp/apc.XXXXXX",
        "engine"             => "On",
        "upload_tmp_dir"     => "/var/www/vhosts/example.com/tmp/uploads",
        "session.save_path"  => "/var/www/vhosts/example.com/tmp/sessions",
        "error_log"          => "/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"          => nil,
        "safe_mode_gid"      => nil,
        "safe_mode_exec_dir "=> nil,
        "default_charset"    => nil,
        "open_basedir"       => "/opt/rh/php55/root/usr/share/php/:/opt/rh/php55/root/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp",
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
      :path     => '/var/www/vhosts/example.com/tmp',
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
    FcgidMaxRequestsPerProcess 4990
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with fpm with scl72' do
    let(:pre_condition){ 'Exec{ path => "/bin" }
                         include yum::prerequisites' }
    let(:params){
      {
        :run_mode         => 'fpm',
        :run_uid          => 'foo',
        :run_gid          => 'bar',
        :php_installation => 'scl72',
      }
    }
    # only test variables that are tuned
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_php__fpm('example.com').with(
      :php_inst_class  => 'php72',
      :tmpdir          => '/var/www/vhosts/example.com/tmp/tmp',
      :logdir          => '/var/www/vhosts/example.com/logs',
      :workdir         => '/var/www/vhosts/example.com',
      :run_user        => 'foo',
      :run_group       => 'bar',
      :additional_envs => {},
      :php_settings    => {
        "apc.mmap_file_mask"    => "/var/www/vhosts/example.com/tmp/apc.XXXXXX",
        "sp.configuration_file" => "/etc/opt/remi/php72/php.d/snuffleupagus-*.rules,/etc/opt/remi/php72/snuffleupagus.d/base.rules,/etc/opt/remi/php72/snuffleupagus.d/example.com.rules",
        "engine"                => "On",
        "upload_tmp_dir"        => "/var/www/vhosts/example.com/tmp/uploads",
        "session.save_path"     => "/var/www/vhosts/example.com/tmp/sessions",
        "error_log"             => "/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"             => nil,
        "safe_mode_gid"         => nil,
        "safe_mode_exec_dir"    => nil,
        "default_charset"       => nil,
        "open_basedir"          => "/opt/remi/php72/root/usr/share/php/:/opt/remi/php72/root/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp",
      },
    ) }
    it { is_expected.to_not contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to contain_class('php::scl::php72') }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :path     => '/var/www/vhosts/example.com/tmp',
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



  <Proxy \"unix:/run/fpm-example.com-socket/0.socket|fcgi://fpm-example.com-0\">
    ProxySet timeout=300
  </Proxy>

  # Redirect to the proxy
  <FilesMatch \\.php$>
    SetHandler proxy:fcgi://fpm-example.com-0
  </FilesMatch>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None



  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with fpm with scl73' do
    let(:pre_condition){ 'Exec{ path => "/bin" }
                         include yum::prerequisites' }
    let(:params){
      {
        :run_mode         => 'fpm',
        :run_uid          => 'foo',
        :run_gid          => 'bar',
        :php_installation => 'scl73',
      }
    }
    # only test variables that are tuned
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_php__fpm('example.com').with(
      :php_inst_class  => 'php73',
      :tmpdir          => '/var/www/vhosts/example.com/tmp/tmp',
      :logdir          => '/var/www/vhosts/example.com/logs',
      :workdir         => '/var/www/vhosts/example.com',
      :run_user        => 'foo',
      :run_group       => 'bar',
      :additional_envs => {},
      :php_settings    => {
        "apc.mmap_file_mask"    => "/var/www/vhosts/example.com/tmp/apc.XXXXXX",
        "sp.configuration_file" => "/etc/opt/remi/php73/php.d/snuffleupagus-*.rules,/etc/opt/remi/php73/snuffleupagus.d/base.rules,/etc/opt/remi/php73/snuffleupagus.d/example.com.rules",
        "engine"                => "On",
        "upload_tmp_dir"        => "/var/www/vhosts/example.com/tmp/uploads",
        "session.save_path"     => "/var/www/vhosts/example.com/tmp/sessions",
        "error_log"             => "/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"             => nil,
        "safe_mode_gid"         => nil,
        "safe_mode_exec_dir"    => nil,
        "default_charset"       => nil,
        "open_basedir"          => "/opt/remi/php73/root/usr/share/php/:/opt/remi/php73/root/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp",
      },
    ) }
    it { is_expected.to_not contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to contain_class('php::scl::php73') }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :path     => '/var/www/vhosts/example.com/tmp',
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



  <Proxy \"unix:/run/fpm-example.com-socket/0.socket|fcgi://fpm-example.com-0\">
    ProxySet timeout=300
  </Proxy>

  # Redirect to the proxy
  <FilesMatch \\.php$>
    SetHandler proxy:fcgi://fpm-example.com-0
  </FilesMatch>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None



  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
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
        :run_mode      => 'fcgid',
        :run_uid       => 'foo',
        :run_gid       => 'bar',
        :logmode       => 'nologs',
        :configuration => {
          'fcgid_options' => {
            'FcgidMaxProcessesPerClass' => 24,
          },
        },
        :php_options   => {
          'safe_mode_exec_bins' => ['/usr/bin/cat'],
        }
      }
    }
    # only test variables that are tuned
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => "/var/www/vhosts/example.com/tmp/tmp",
      :cgi_type         => 'php',
      :cgi_type_options => {
        "engine"             => "On",
        "upload_tmp_dir"     => "/var/www/vhosts/example.com/tmp/uploads",
        "session.save_path"  => "/var/www/vhosts/example.com/tmp/sessions",
        "error_log"          => nil,
        "safe_mode"          => "On",
        "safe_mode_gid"      => "On",
        "safe_mode_exec_dir" => "/var/www/vhosts/example.com/bin",
        "default_charset"    => nil,
        "open_basedir"       => "/usr/share/php/:/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp",
        "apc.mmap_file_mask" => "/var/www/vhosts/example.com/tmp/apc.XXXXXX",
      },
      :owner            => 'foo',
      :group            => 'bar',
      :notify           => 'Service[apache]',
    ) }
    # with no log it is_expected.to be absent
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com').with_ensure('absent') }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :path => '/var/www/vhosts/example.com/tmp',
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
    FcgidMaxRequestsPerProcess 4990
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
    FcgidMaxProcessesPerClass 24
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with mod_fcgid and params II' do
    let(:facts){default_facts.merge(:operatingsystemmajrelease => '6')}
    let(:params){
      {
        :run_mode      => 'fcgid',
        :run_uid       => 'foo',
        :run_gid       => 'bar',
        :manage_webdir => false,
        :php_options   => {
          'pear'                => true,
          'safe_mode_exec_bins' => ['/usr/bin/cat'],
        }
      }
    }
    # only test variables that are tuned
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to_not contain_apache__vhost__webdir('example.com') }
    it { is_expected.to contain_class('mod_fcgid') }
    it { is_expected.to contain_class('php::mod_fcgid') }
    it { is_expected.to contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
    it { is_expected.to contain_mod_fcgid__starter('example.com').with(
      :tmp_dir          => '/var/www/vhosts/example.com/tmp/tmp',
      :cgi_type         => 'php',
      :cgi_type_options => {
        "engine"             => "On",
        "upload_tmp_dir"     => "/var/www/vhosts/example.com/tmp/uploads",
        "session.save_path"  => "/var/www/vhosts/example.com/tmp/sessions",
        "error_log"          => "/var/www/vhosts/example.com/logs/php_error_log",
        "safe_mode"          => "On",
        "safe_mode_gid"      => "On",
        "safe_mode_exec_dir" => "/var/www/vhosts/example.com/bin",
        "default_charset"    => nil,
        "open_basedir"       => "/usr/share/php/:/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp",
        "apc.mmap_file_mask" => "/var/www/vhosts/example.com/tmp/apc.XXXXXX",
      },
      :owner            => 'foo',
      :group            => 'bar',
      :notify           => 'Service[apache]',
    ) }
    # with no log it is_expected.to be absent
    it { is_expected.to contain_file('/etc/logrotate.d/php_example.com') }

    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__phpdirs('example.com').with(
      :ensure => 'present',
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


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <IfModule mod_fcgid.c>
    SuexecUserGroup foo bar
    FcgidMaxRequestsPerProcess 4990
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +ExecCGI


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
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
          'pear'                => true,
          'safe_mode_exec_bins' => ['/usr/bin/cat'],
        }
      }
    }
    # only test variables that are tuned
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_apache__vhost__webdir('example.com').with_ensure('absent') }
    it { is_expected.to_not contain_class('mod_fcgid') }
    it { is_expected.to_not contain_class('php::mod_fcgid') }
    it { is_expected.to_not contain_class('apache::include::mod_fcgid') }
    it { is_expected.to_not contain_class('php::scl::php54') }
    it { is_expected.to_not contain_class('php::scl::php55') }
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
