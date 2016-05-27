require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache', :type => 'class' do
  let(:default_facts) {
    { :operatingsystem => 'CentOS', }
  }
  let(:facts){ default_facts }
  let(:pre_condition){'Exec{path => "/bin"}'}
  describe 'with standard' do
    it { should compile.with_all_deps }

    it { should contain_class('apache::base') }
    it { should_not contain_class('apache::status') }
    it { should_not contain_class('shorewall::rules::http') }
    it { should_not contain_class('apache::ssl') }
    context 'on Debian' do
      let(:facts) {
        {
          :operatingsystem => 'Debian',
        }
      }
      it { should compile.with_all_deps }
      it { should contain_class('apache::debian') }
    end
  end
  describe 'with params' do
    let(:facts) {
      default_facts.merge({
        :concat_basedir => '/var/lib/puppet/concat'
      })
    }
    let(:params){
      {
        :manage_shorewall => true,
        # there is puppet-librarian bug in using that module
        #:manage_munin     => true,
        :ssl              => true,
      }
    }
    it { should compile.with_all_deps }

    it { should contain_class('apache::base') }
    it { should_not contain_class('apache::status') }
    it { should contain_class('shorewall::rules::http') }
    it { should contain_class('apache::ssl') }
  end
end
