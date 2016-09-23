require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache', :type => 'class' do
  let(:default_facts) {
    {
      :operatingsystem => 'CentOS',
    }
  }
  let(:facts){ default_facts }
  let(:pre_condition){'Exec{path => "/bin"}' }
  describe 'with standard' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('apache::base') }
    it { is_expected.to_not contain_class('apache::status') }
    it { is_expected.to_not contain_class('shorewall::rules::http') }
    it { is_expected.to_not contain_class('apache::ssl') }
    context 'on Debian' do
      let(:facts) {
        {
          :operatingsystem => 'Debian',
        }
      }
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('apache::debian') }
    end
  end
  describe 'with params' do
    let(:facts) {
      default_facts.merge({
        :concat_basedir => '/var/lib/puppet/concat'
      })
    }
    let(:pre_condition){'Exec{path => "/bin"}
                      include ::augeas
                      include ::shorewall'}
    let(:params){
      {
        :manage_shorewall => true,
        # there is puppet-librarian bug in using that module
        #:manage_munin     => true,
        :ssl              => true,
      }
    }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('apache::base') }
    it { is_expected.to_not contain_class('apache::status') }
    it { is_expected.to contain_class('shorewall::rules::http') }
    it { is_expected.to contain_class('apache::ssl') }
  end
end
