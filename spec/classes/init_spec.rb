require 'spec_helper'
describe 'ptpd' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({:hostname => 'somehostname', :domain => 'xyz'})
      end
      let(:pre_condition) { }

      context 'single instance with defaults for all parameters' do
        let (:params) {{
          :ptpengine_interface => 'eth0',
          :single_instance     => true,
        }}
        it { is_expected.to contain_class('ptpd') }
        it { is_expected.to contain_package('ptpd-libcck').with_ensure('present') }
        it { is_expected.to contain_service('ptpd').with({
          'ensure'     => 'running',
          'enable'     => true,
          'hasstatus'  => true,
          'hasrestart' => true,
        }) }
        it { is_expected.to contain_ptpd__instance('ptpd') }
        it { is_expected.to contain_file('/etc/sysconfig/ptpd').with_ensure('file') }
        it { is_expected.to contain_file('/etc/sysconfig/ptpd').with_content(/PTPD_CONFIG_FILE="\/etc\/ptpd\.conf"/) }
        it { is_expected.to contain_file('/etc/sysconfig/ptpd').with_content(/PTPD_PID_FILE="\/var\/run\/ptpd\.lock"/) }
        it { is_expected.to contain_file('/etc/sysconfig/ptpd').with_content(/PTPD_STATUS_FILE="\/var\/run\/ptpd\.status"/) }
        it { is_expected.to contain_file('/etc/sysconfig/ptpd').that_notifies('Service[ptpd]') }
        it { is_expected.to contain_file('/etc/sysconfig/ptpd').that_requires('Package[ptpd-libcck]') }

        context 'with a custom package name' do
          let(:params) do
            super().merge({:package_name => 'some-ptpd'})
          end
          it { is_expected.to contain_package('some-ptpd') }
        end
      end

      context 'with parameters to completely remove' do
        let(:params) {{
          :package_ensure   => 'absent',
          :conf_file_ensure => 'absent',
          :service_ensure   => 'stopped',
          :service_enable   => 'false',
        }}
        it { is_expected.to contain_package('ptpd-libcck').with_ensure('absent') }
        it { is_expected.to contain_service('ptpd').with_ensure('stopped') }
        it { is_expected.to contain_service('ptpd').with_enable('false') }
        it { is_expected.to contain_file('/etc/sysconfig/ptpd').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/sysconfig/ptpd').that_requires('Service[ptpd]') }
        it { is_expected.to contain_ptpd__instance('ptpd').with_conf_file_ensure('absent') }
      end

      context 'multi instance with defaults for all parameters' do
        let (:params) {{
          :single_instance => false,
        }}
        it { is_expected.to contain_class('ptpd') }
        it { is_expected.to contain_package('ptpd-libcck') }
        it { is_expected.not_to contain_service('ptpd') }

        context 'with a custom package name' do
          let(:params) do
            super().merge({:package_name => 'some-ptpd'})
          end
          it { is_expected.to contain_package('some-ptpd') }
        end
      end
    end
  end
end
