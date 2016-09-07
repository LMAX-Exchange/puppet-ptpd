require 'spec_helper'
describe 'ptpd' do

  context 'with defaults for all parameters' do
    let (:params) {{
      :ptpengine_interface => 'eth0',
    }}
    it { is_expected.to contain_class('ptpd') }

    it { is_expected.to contain_package('ptpd-linuxphc') }

    it { is_expected.to contain_service('ptpd').with({
      'ensure'     => 'running',
      'enable'     => true,
      'hasstatus'  => true,
      'hasrestart' => true,
    }) }

    it { is_expected.to contain_file('/etc/ptpd.conf').with({
      'ensure' => 'file',
      'owner'  => 'root',
      'group'  => 'root',
    }) }

    it { is_expected.to contain_logrotate__rule('ptpd') }
  end

  context 'with a custom package name' do
    let(:params) {{
      :ptpengine_interface => 'eth0',
      :package_name        => 'some-ptpd'
    }}

    it { is_expected.to contain_package('some-ptpd') }
  end

  context 'with manage_logrotate=false' do
    let(:params) {{
      :ptpengine_interface => 'eth0',
      :manage_logrotate => false,
    }}

    it "should not contain a logrotate rule" do
      expect { should_not contain_logrotate__rule('ptpd') }
    end
  end
end
