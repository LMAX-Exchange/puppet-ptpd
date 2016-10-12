require 'spec_helper'
describe 'ptpd' do
  let (:facts) {{
    :osfamily => 'RedHat',
  }}

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
    it { is_expected.to contain_file('/etc/ptpd.conf').with_content(/global:statistics_file=\/var\/log\/ptpd\.stats/) }
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

  context 'with service_ensure=stopped' do
    let(:params) {{
      :ptpengine_interface => 'eth0',
      :service_ensure => 'stopped',
    }}
    it "should not have a running ptpd service" do
      expect { should contain_service('ptpd').with_ensure('stopped') }
    end
  end

  context 'with log_statistics=false' do
    let(:params) {{
      :ptpengine_interface => 'eth0',
      :log_statistics => false,
    }}
    it "should have no statistics file in the config" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/global:statistics_file=$/)
    end
  end

  context 'with servo_adev_locked_threshold_*_hw settings' do
    let(:params) {{
      :ptpengine_interface => 'eth0',
      :servo_adev_locked_threshold_low_hw => '15',
      :servo_adev_locked_threshold_high_hw => '45',
    }}
    it "should have different adev hw servo values" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_low_hw=15$/)
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_high_hw=45$/)
    end
  end
end
