require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::template', :type => 'define' do
  let(:title){ 'example.com' }
  let(:facts){
    {
      :fqdn                       => 'apache.example.com',
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '7',
      :selinux                    => true,
      :os => {
        'release' => {
          'major' => '7',
        },
      }
    }
  }
  let(:pre_condition) {
    'include apache'
  }
  describe 'with standard' do
    it { is_expected.to contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => false,
      :run_mode       => 'normal',
      :ssl_mode       => false,
      :logmode        => 'default',
      :mod_security   => false,
      :htpasswd_file  => 'absent',
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



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
  describe 'with params' do
    let(:params){
      {
        :do_includes    => true,
        :ssl_mode       => true,
        :logmode        => 'anonym',
        :mod_security   => false,
        :htpasswd_file  => true,
      }
    }
    it { is_expected.to contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => true,
      :run_mode       => 'normal',
      :ssl_mode       => true,
      :logmode        => 'anonym',
      :mod_security   => false,
      :htpasswd_file  => true,
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /var/www/vhosts/example.com/logs/access_log noip



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +Includes
    AuthType Basic
    AuthName \"Access fuer example.com\"
    AuthUserFile /var/www/htpasswds/example.com
    require valid-user

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
<VirtualHost *:443 >

  Include include.d/defaults.inc
  Include include.d/ssl_defaults.inc

  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /var/www/vhosts/example.com/logs/access_log noip



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +Includes
    AuthType Basic
    AuthName \"Access fuer example.com\"
    AuthUserFile /var/www/htpasswds/example.com
    require valid-user

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
  describe 'with params II' do
    let(:params){
      {
        :do_includes    => true,
        :ssl_mode       => 'force',
        :logmode        => 'semianonym',
        :mod_security   => false,
        :htpasswd_file  => true,
      }
    }
    it { is_expected.to contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => true,
      :run_mode       => 'normal',
      :ssl_mode       => 'force',
      :logmode        => 'semianonym',
      :mod_security   => false,
      :htpasswd_file  => true,
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log noip



  RewriteEngine On
  RewriteCond %{HTTPS} !=on
  RewriteCond %{HTTP:X-Forwarded-Proto} !=https
  RewriteRule (.*) https://%{SERVER_NAME}$1 [R=permanent,L]
  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +Includes
    AuthType Basic
    AuthName \"Access fuer example.com\"
    AuthUserFile /var/www/htpasswds/example.com
    require valid-user

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
<VirtualHost *:443 >

  Include include.d/defaults.inc
  Include include.d/ssl_defaults.inc

  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log noip



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +Includes
    AuthType Basic
    AuthName \"Access fuer example.com\"
    AuthUserFile /var/www/htpasswds/example.com
    require valid-user

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
  describe 'with params III' do
    let(:params){
      {
        :do_includes    => false,
        :ssl_mode       => 'only',
        :logmode        => 'nologs',
        :mod_security   => true,
        :htpasswd_file  => 'absent',
      }
    }
    it { is_expected.to contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => false,
      :run_mode       => 'normal',
      :ssl_mode       => 'only',
      :logmode        => 'nologs',
      :mod_security   => true,
      :htpasswd_file  => 'absent',
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:443 >

  Include include.d/defaults.inc
  Include include.d/ssl_defaults.inc

  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /dev/null %%



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None


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

  describe 'with params IV' do
    let(:params){
      {
        :do_includes    => false,
        :ssl_mode       => 'only',
        :logmode        => 'nologs',
        :mod_security   => true,
        :htpasswd_file  => 'absent',
        :configuration  => {
          'ssl_certificate_file' => '/tmp/cert',
          'ssl_certificate_key_file' => '/tmp/key',
          'ssl_certificate_chain_file' => '/tmp/chain',
          'hsts' => true,
        }
      }
    }
    it { is_expected.to contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => false,
      :run_mode       => 'normal',
      :ssl_mode       => 'only',
      :logmode        => 'nologs',
      :mod_security   => true,
      :htpasswd_file  => 'absent',
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:443 >

  Include include.d/defaults.inc
  Include include.d/ssl_defaults.inc
  SSLCertificateFile /tmp/cert
  SSLCertificateKeyFile /tmp/key
  SSLCertificateChainFile /tmp/chain
  Header add Strict-Transport-Security \"max-age=15768000\"

  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /dev/null %%



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None


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

  describe 'with auth_mellon params' do
    let(:params){
      {
        :do_includes    => false,
        :ssl_mode       => 'only',
        :logmode        => 'nologs',
        :mod_security   => true,
        :htpasswd_file  => 'absent',
        :configuration  => {
          'ssl_certificate_file' => '/tmp/cert',
          'ssl_certificate_key_file' => '/tmp/key',
          'ssl_certificate_chain_file' => '/tmp/chain',
          'hsts' => true,
          'auth_mellon' => {
            'login_url' => 'https://login.example.com',
            'signing_certs' => [
        '-----BEGIN CERTIFICATE-----
cert1
-----END CERTIFICATE-----
','-----BEGIN CERTIFICATE-----
cert2
-----END CERTIFICATE-----
' ],
            'sp_key' => 'my_key',
            'sp_cert' => 'my_cert',
            'idp_ca' => 'ca_cert',
          },
        }
      }
    }
    it { is_expected.to contain_class('apache::module::auth_mellon') }
    it { is_expected.to contain_apache__module__auth_mellon__entity('example.com').with(
      :login_url => 'https://login.example.com',
      :signing_certs => [
        '-----BEGIN CERTIFICATE-----
cert1
-----END CERTIFICATE-----
','-----BEGIN CERTIFICATE-----
cert2
-----END CERTIFICATE-----
'],
      :sp_key => 'my_key',
      :sp_cert => 'my_cert',
      :idp_ca => 'ca_cert',
    )}

    {
      '/etc/httpd/mellon/example.com-idp-metadata.xml' => '<EntityDescriptor ID="example.com" xmlns="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" entityID="https://login.example.com/saml">
  <IDPSSODescriptor WantAuthnRequestsSigned="true" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <KeyDescriptor use="signing">
      <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
        <X509Data>
          <X509Certificate>
cert1
          </X509Certificate>
        </X509Data>
      </KeyInfo>
    </KeyDescriptor>
    <KeyDescriptor use="signing">
      <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
        <X509Data>
          <X509Certificate>
cert2
          </X509Certificate>
        </X509Data>
      </KeyInfo>
    </KeyDescriptor>
    <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:emailAddress</NameIDFormat>
    <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</NameIDFormat>
    <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://login.example.com/saml_post/"/>
    <saml:Attribute NameFormat="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" Name="" FriendlyName="email"></saml:Attribute>
  </IDPSSODescriptor>
</EntityDescriptor>
',
      '/etc/httpd/mellon/example.com.crt' => 'my_cert',
      '/etc/httpd/mellon/example.com.key' => 'my_key',
      '/etc/httpd/mellon/example.com-ca.crt' => 'ca_cert',
    }.each do |file,content|
      it { is_expected.to contain_file(file).with(
        :owner  => 'root',
        :group  => 'apache',
        :mode   => '0640',
        :notify => 'Service[apache]',
      )}
      it { is_expected.to contain_file(file).with_content(content)}
    end

    it { is_expected.to contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => false,
      :run_mode       => 'normal',
      :ssl_mode       => 'only',
      :logmode        => 'nologs',
      :mod_security   => true,
      :htpasswd_file  => 'absent',
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:443 >

  Include include.d/defaults.inc
  Include include.d/ssl_defaults.inc
  SSLCertificateFile /tmp/cert
  SSLCertificateKeyFile /tmp/key
  SSLCertificateChainFile /tmp/chain
  Header add Strict-Transport-Security \"max-age=15768000\"

  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /dev/null %%



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None

    Require valid-user
    AuthType \"Mellon\"
    MellonEnable \"auth\"

    # MellonVariable is used to select the name of the cookie which
    # mod_auth_mellon should use to remember the session id. If you
    # want to have different sites running on the same host, then
    # you will have to choose a different name for the cookie for each
    # site.
    MellonVariable \"c-example.com\"

    MellonSecureCookie On
    #MellonCookieSameSite strict

    MellonUser \"NAME_ID\"
    MellonSessionDump Off
    MellonSamlResponseDump Off

    MellonSessionLength 86400

    MellonIdPMetadataFile /etc/httpd/mellon/example.com-idp-metadata.xml

    MellonSPPrivateKeyFile /etc/httpd/mellon/example.com.key
    MellonSPCertFile /etc/httpd/mellon/example.com.crt

    MellonIdPCAFile /etc/httpd/mellon/example.com-ca.crt


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

  describe 'with auth_mellon params as file source' do
    let(:params){
      {
        :do_includes    => false,
        :ssl_mode       => 'only',
        :logmode        => 'nologs',
        :mod_security   => true,
        :htpasswd_file  => 'absent',
        :configuration  => {
          'ssl_certificate_file' => '/tmp/cert',
          'ssl_certificate_key_file' => '/tmp/key',
          'ssl_certificate_chain_file' => '/tmp/chain',
          'hsts' => true,
          'auth_mellon' => {
            'login_url' => 'https://login.example.com',
            'signing_certs' => [
        '-----BEGIN CERTIFICATE-----
cert1
-----END CERTIFICATE-----
','-----BEGIN CERTIFICATE-----
cert2
-----END CERTIFICATE-----
' ],
            'sp_key' => 'puppet:///my_key',
            'sp_cert' => 'puppet:///my_cert',
            'idp_ca' => 'puppet:///ca_cert',
          },
        }
      }
    }
    it { is_expected.to contain_class('apache::module::auth_mellon') }
    it { is_expected.to contain_apache__module__auth_mellon__entity('example.com').with(
      :login_url => 'https://login.example.com',
      :signing_certs => [
        '-----BEGIN CERTIFICATE-----
cert1
-----END CERTIFICATE-----
','-----BEGIN CERTIFICATE-----
cert2
-----END CERTIFICATE-----
'],
      :sp_key => 'puppet:///my_key',
      :sp_cert => 'puppet:///my_cert',
      :idp_ca => 'puppet:///ca_cert',
    )}

    it { is_expected.to contain_file('/etc/httpd/mellon/example.com-idp-metadata.xml').with(
      :owner  => 'root',
      :group  => 'apache',
      :mode   => '0640',
      :notify => 'Service[apache]',
    )}
    it { is_expected.to contain_file('/etc/httpd/mellon/example.com-idp-metadata.xml').with_content('<EntityDescriptor ID="example.com" xmlns="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" entityID="https://login.example.com/saml">
  <IDPSSODescriptor WantAuthnRequestsSigned="true" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <KeyDescriptor use="signing">
      <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
        <X509Data>
          <X509Certificate>
cert1
          </X509Certificate>
        </X509Data>
      </KeyInfo>
    </KeyDescriptor>
    <KeyDescriptor use="signing">
      <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
        <X509Data>
          <X509Certificate>
cert2
          </X509Certificate>
        </X509Data>
      </KeyInfo>
    </KeyDescriptor>
    <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:emailAddress</NameIDFormat>
    <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</NameIDFormat>
    <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://login.example.com/saml_post/"/>
    <saml:Attribute NameFormat="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" Name="" FriendlyName="email"></saml:Attribute>
  </IDPSSODescriptor>
</EntityDescriptor>
') }
    {
      '/etc/httpd/mellon/example.com.crt' => 'puppet:///my_cert',
      '/etc/httpd/mellon/example.com.key' => 'puppet:///my_key',
      '/etc/httpd/mellon/example.com-ca.crt' => 'puppet:///ca_cert',
    }.each do |file,source|
      it { is_expected.to contain_file(file).with(
        :owner  => 'root',
        :group  => 'apache',
        :mode   => '0640',
        :source => source,
        :notify => 'Service[apache]',
      )}
    end

    it { is_expected.to contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => false,
      :run_mode       => 'normal',
      :ssl_mode       => 'only',
      :logmode        => 'nologs',
      :mod_security   => true,
      :htpasswd_file  => 'absent',
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { is_expected.to contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:443 >

  Include include.d/defaults.inc
  Include include.d/ssl_defaults.inc
  SSLCertificateFile /tmp/cert
  SSLCertificateKeyFile /tmp/key
  SSLCertificateChainFile /tmp/chain
  Header add Strict-Transport-Security \"max-age=15768000\"

  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /dev/null %%



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None

    Require valid-user
    AuthType \"Mellon\"
    MellonEnable \"auth\"

    # MellonVariable is used to select the name of the cookie which
    # mod_auth_mellon should use to remember the session id. If you
    # want to have different sites running on the same host, then
    # you will have to choose a different name for the cookie for each
    # site.
    MellonVariable \"c-example.com\"

    MellonSecureCookie On
    #MellonCookieSameSite strict

    MellonUser \"NAME_ID\"
    MellonSessionDump Off
    MellonSamlResponseDump Off

    MellonSessionLength 86400

    MellonIdPMetadataFile /etc/httpd/mellon/example.com-idp-metadata.xml

    MellonSPPrivateKeyFile /etc/httpd/mellon/example.com.key
    MellonSPCertFile /etc/httpd/mellon/example.com.crt

    MellonIdPCAFile /etc/httpd/mellon/example.com-ca.crt


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
end
