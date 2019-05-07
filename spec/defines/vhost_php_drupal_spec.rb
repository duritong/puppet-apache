require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::php::drupal', :type => 'define' do
  let(:title){ 'example.com' }
  let(:facts){
    {
      :fqdn => 'apache.example.com',
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '7',
      :os                         => {
        'family' => 'RedHat',
        'release' => {
          'major' => '7',
        },
      },
      :selinux                    => true,
    }
  }
  describe 'with standard' do
    it { is_expected.to contain_file('/etc/cron.d/drupal_cron_example.com').with(
      :content => "0   *   *   *   *   apache wget -O - -q -t 1 http://example.com/cron.php\n",
      :owner   => 'root',
      :group   => 0,
      :mode    => '0644',
    )}
    # only test the differences from the default
    it { is_expected.to contain_apache__vhost__php__webapp('example.com').with(
      :manage_directories => false,
      :template_partial   => 'apache/vhosts/php_drupal/partial.erb',
      :manage_config      => false,
      :php_settings       => {
        'magic_quotes_gpc'              => 0,
        'register_globals'              => 0,
        'session.auto_start'            => 0,
        'mbstring.http_input'           => 'pass',
        'mbstring.http_output'          => 'pass',
        'mbstring.encoding_translation' => 0,
      }
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



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None

    php_admin_value apc.mmap_file_mask /var/www/vhosts/example.com/tmp/apc.XXXXXX
    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value magic_quotes_gpc 0
    php_admin_value mbstring.encoding_translation 0
    php_admin_value mbstring.http_input pass
    php_admin_value mbstring.http_output pass
    php_admin_value open_basedir /usr/share/php/:/usr/share/pear/:/var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/vhosts/example.com/tmp
    php_admin_value register_globals 0
    php_admin_value session.auto_start 0
    php_admin_value session.save_path /var/www/vhosts/example.com/tmp/sessions
    php_admin_value upload_tmp_dir /var/www/vhosts/example.com/tmp/uploads

    # Protect files and directories from prying eyes.
    <FilesMatch \"\\.(engine|inc|info|install|module|profile|po|sh|.*sql|theme|tpl(\\.php)?|xtmpl)$|^(code-style\\.pl|Entries.*|Repository|Root|Tag|Template)$\">
      Deny From All
    </FilesMatch>

    # Customized error messages.
    ErrorDocument 404 /index.php

    RewriteEngine on
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]

  </Directory>
  <Directory \"/var/www/vhosts/example.com/www/files/\">
    SetHandler Drupal_Security_Do_Not_Remove_See_SA_2006_006
    Options None
    Options +FollowSymLinks
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
    it { is_expected.to contain_file('/etc/cron.d/drupal_cron_example.com').with(
      :content => "0   *   *   *   *   apache wget -O - -q -t 1 http://example.com/cron.php\n",
      :owner   => 'root',
      :group   => 0,
      :mode    => '0644',
    )}
    # only test variables that are tuned
    it { is_expected.to contain_apache__vhost__php__webapp('example.com').with(
      :run_mode                       => 'fcgid',
      :run_uid                        => 'foo',
      :run_gid                        => 'bar',
      :manage_directories             => false,
      :template_partial               => 'apache/vhosts/php_drupal/partial.erb',
      :manage_config                  => false,
      :php_settings                   => {
        'magic_quotes_gpc'              => 0,
        'register_globals'              => 0,
        'session.auto_start'            => 0,
        'mbstring.http_input'           => 'pass',
        'mbstring.http_output'          => 'pass',
        'mbstring.encoding_translation' => 0,
      },
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

    # Protect files and directories from prying eyes.
    <FilesMatch \"\\.(engine|inc|info|install|module|profile|po|sh|.*sql|theme|tpl(\\.php)?|xtmpl)$|^(code-style\\.pl|Entries.*|Repository|Root|Tag|Template)$\">
      Deny From All
    </FilesMatch>

    # Customized error messages.
    ErrorDocument 404 /index.php

    RewriteEngine on
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]

  </Directory>
  <Directory \"/var/www/vhosts/example.com/www/files/\">
    SetHandler Drupal_Security_Do_Not_Remove_See_SA_2006_006
    Options None
    Options +FollowSymLinks
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
end
