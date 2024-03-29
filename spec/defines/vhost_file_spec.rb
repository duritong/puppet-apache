require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::file', :type => 'define' do
  let(:title){ 'example.com' }
  let(:facts){
    {
      :networking => {
        :fqdn => 'apache.example.com',
      },
      :os                         => {
        'selinux' => { 'enabled' => true },
        'name' => 'CentOS',
        'family' => 'RedHat',
        'release' => {
          'major' => '7',
        },
      },
    }
  }
  let(:pre_condition) {
    'include apache'
  }
  describe 'with standard' do
    it { is_expected.to contain_file('example.com.conf').with(
      :ensure  => 'present',
      :source  => [ "puppet:///modules/site_apache/vhosts.d/apache.example.com/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d//example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/CentOS.7/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/CentOS/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/CentOS.7/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/CentOS/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/example.com.conf" ],
      :path    => '/etc/httpd/vhosts.d/example.com.conf',
      :require => 'File[vhosts_dir]',
      :notify  => 'Service[apache]',
      :owner   => 'root',
      :group   => 0,
      :mode    => '0640',
    )}
    it { is_expected.to_not contain_file('/var/www/htpasswds/example.com') }
    it { is_expected.to_not contain_class('apache::includes') }
    it { is_expected.to_not contain_class('apache::mod_macro') }
    it { is_expected.to_not contain_class('apache::noiplog') }
    it { is_expected.to_not contain_class('mod_security') }
  end
  context 'on centos' do
    let(:facts){
      {
        :networking => {
          :fqdn                       => 'apache.example.com',
        },
        :os                         => {
          'selinux' => { 'enabled' => true },
          'name' => 'CentOS',
          'family' => 'RedHat',
          'release' => {
            'major' => '7',
          },
        },
        :selinux                    => true,
      }
    }
    it { is_expected.to contain_file('example.com.conf').with(
      :ensure  => 'present',
      :source  => [ "puppet:///modules/site_apache/vhosts.d/apache.example.com/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d//example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/CentOS.7/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/CentOS/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/CentOS.7/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/CentOS/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/example.com.conf" ],
      :path    => '/etc/httpd/vhosts.d/example.com.conf',
      :require => 'File[vhosts_dir]',
      :notify  => 'Service[apache]',
      :owner   => 'root',
      :group   => 0,
      :mode    => '0640',
    )}
    it { is_expected.to_not contain_file('/var/www/htpasswds/example.com') }
    it { is_expected.to_not contain_class('apache::includes') }
    it { is_expected.to_not contain_class('apache::mod_macro') }
    it { is_expected.to_not contain_class('apache::noiplog') }
    it { is_expected.to_not contain_class('mod_security') }
    context 'with params' do
      let(:params) {
        {
          :vhost_destination => '/tmp/a/example.com.conf',
          :vhost_source      => 'modules/my_module/example.com.conf',
          :htpasswd_file     => true,
          :do_includes       => true,
          :mod_security      => true,
          :use_mod_macro     => true,
          :logmode           => 'anonym',
        }
      }
      it { is_expected.to contain_file('example.com.conf').with(
        :ensure  => 'present',
        :source  => 'puppet:///modules/my_module/example.com.conf',
        :path    => '/tmp/a/example.com.conf',
        :require => 'File[vhosts_dir]',
        :notify  => 'Service[apache]',
        :owner   => 'root',
        :group   => 0,
        :mode    => '0640',
      )}
      it { is_expected.to contain_file('/var/www/htpasswds/example.com').with(
        :source  => [ "puppet:///modules/site_apache/htpasswds/apache.example.com/example.com",
                      "puppet:///modules/site_apache/htpasswds//example.com",
                      "puppet:///modules/site_apache/htpasswds/example.com" ],
        :owner   => 'root',
        :group   => 'apache',
        :mode    => '0640',
      )}
      it { is_expected.to contain_class('apache::includes') }
      it { is_expected.to contain_class('apache::mod_macro') }
      it { is_expected.to contain_class('apache::noiplog') }
      it { is_expected.to contain_class('mod_security') }
    end
    context 'with content' do
      let(:params) {
        {
          :content => "<VirtualHost *:80>\n  Servername example.com\n</VirtualHost>"
        }
      }
      it { is_expected.to contain_file('example.com.conf').with(
        :ensure  => 'present',
        :path    => '/etc/httpd/vhosts.d/example.com.conf',
        :require => 'File[vhosts_dir]',
        :notify  => 'Service[apache]',
        :owner   => 'root',
        :group   => 0,
        :mode    => '0640',
      )}
      it { is_expected.to contain_file('example.com.conf').with_content(
"<VirtualHost *:80>
  Servername example.com
</VirtualHost>"
      )}
      it { is_expected.to_not contain_file('/var/www/htpasswds/example.com') }
    end
  end
end
