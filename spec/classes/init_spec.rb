require 'spec_helper'
describe 'ptpd' do
  let (:facts) {{
    :osfamily => 'RedHat',
  }}

  context 'single instance with defaults for all parameters' do
    let (:params) {{
      :ptpengine_interface => 'eth0',
      :single_instance     => true,
    }}
    it { is_expected.to contain_class('ptpd') }
    it { is_expected.to contain_package('ptpd-linuxphc') }
    it { is_expected.to contain_service('ptpd').with({
      'ensure'     => 'running',
      'enable'     => true,
      'hasstatus'  => true,
      'hasrestart' => true,
    }) }
    it { is_expected.to contain_ptpd__instance('ptpd') }
    it { is_expected.to contain_file('/etc/sysconfig/ptpd').with_content(/PTPD_CONFIG_FILE="\/etc\/ptpd\.conf"/) }
    it { is_expected.to contain_file('/etc/sysconfig/ptpd').with_content(/PTPD_PID_FILE="\/var\/run\/ptpd\.lock"/) }
    it { is_expected.to contain_file('/etc/sysconfig/ptpd').with_content(/PTPD_STATUS_FILE="\/var\/run\/ptpd\.status"/) }

    context 'with a custom package name' do
      let(:params) do
        super().merge({:package_name => 'some-ptpd'})
      end
      it { is_expected.to contain_package('some-ptpd') }
    end

    context 'with service_ensure=stopped' do
      let(:params) do
        super().merge({:service_ensure => 'stopped'})
      end
      it "should not have a running ptpd service" do
        expect { is_expected.to contain_service('ptpd').with_ensure('stopped') }
      end
    end
  end

  context 'multi instance with defaults for all parameters' do
    let (:params) {{
      :single_instance => false,
    }}
    it { is_expected.to contain_class('ptpd') }
    it { is_expected.to contain_package('ptpd-linuxphc') }
    it { is_expected.not_to contain_service('ptpd') }

    context 'with a custom package name' do
      let(:params) do
        super().merge({:package_name => 'some-ptpd'})
      end
      it { is_expected.to contain_package('some-ptpd') }
    end
  end
end
