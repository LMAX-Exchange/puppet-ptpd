require 'spec_helper'
describe 'ptpd::instance' do
  let (:facts) {{
    :osfamily => 'RedHat',
  }}

  context 'single instance with defaults for all parameters' do
    let (:name) { 'ptpd' }
    let (:title) { 'ptpd' }
    let (:params) {{
      :single_instance             => true,
      :ptpengine_interface         => 'eth0',
      :clock_extra_clocks          => 'linuxphc:/dev/ptp0:phc0',
      :clock_master_clock_name     => 'syst',
      :ptpengine_log_sync_interval => '-3',
      :clock_disabled_clock_names  => 'foo',
    }}
    it { is_expected.to contain_file('/etc/ptpd.conf').with({
      'ensure' => 'file',
      'owner'  => 'root',
      'group'  => 'root',
    }) }
    it { is_expected.to contain_file('/etc/ptpd.conf').with_content(/^ptpengine:interface=eth0$/) }
    it { is_expected.to contain_file('/etc/ptpd.conf').with_content(/^global:statistics_file=\/var\/log\/ptpd\.stats/) }
    it { is_expected.to contain_logrotate__rule('ptpd') }
    it "should have hardware specific servo KP/KI values" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:kp=0\.7/)
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:ki=0\.3/)
    end
    it "should have sane defaults for adev thresholds" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_low_hw=50\.000000$/)
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_high_hw=500.000000$/)
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_low=200\.000000$/)
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_high=2000\.000000$/)
    end
    it "should contain a logrotate rule" do
      expect { should contain_logrotate__rule('ptpd') }
    end
    it "should have clock:extra_clocks=linuxphc:/dev/ptp0:phc0" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/^clock:extra_clocks=linuxphc:\/dev\/ptp0:phc0$/)
    end
    it "should have clock:master_clock_name=syst" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/^clock:master_clock_name=syst$/)
    end
    it "should have clock:disabled_clock_names=foo" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/^clock:disabled_clock_names=foo$/)
    end
    it "should have panic mode enabled" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/^ptpengine:panic_mode=y$/)
    end
    it "should have panic mode duration set to 30 seconds" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/^ptpengine:panic_mode_duration=30$/)
    end
    it "should have a sync interval set to -3" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/^ptpengine:log_sync_interval=-3$/)
    end
    it "should have a cpu pinning of 0" do
      is_expected.to contain_file('/etc/ptpd.conf').with_content(/^global:cpuaffinity_cpucore=0$/)
    end

    context 'with conf_file_ensure=absnet' do
      let(:params) do
        super().merge({
          :conf_file_ensure => 'absent',
        })
      end
      it { is_expected.to contain_file('/etc/ptpd.conf').with_ensure('absent') }
    end

    context 'with manage_logrotate=false' do
      let(:params) do
        super().merge({
          :manage_logrotate => false,
        })
      end
      it "should not contain a logrotate rule" do
        expect { should_not contain_logrotate__rule('ptpd') }
      end
    end

    context 'with log_statistics=false' do
      let(:params) do
        super().merge({
          :log_statistics => false,
        })
      end
      it "should have no statistics file in the config" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/global:statistics_file=$/)
      end
    end

    context 'with servo_adev_locked_threshold_* settings' do
      let(:params) do
        super().merge({
          :servo_adev_locked_threshold_low_hw  => '15',
          :servo_adev_locked_threshold_high_hw => '45',
          :servo_adev_locked_threshold_low     => '115',
          :servo_adev_locked_threshold_high    => '145',
        })
      end
      it "should have different adev hw servo values" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_low_hw=15$/)
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_high_hw=45$/)
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_low=115$/)
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:adev_locked_threshold_high=145$/)
      end
    end

    context 'with ptpengine_hardware_timestamping=false' do
      let(:params) do
        super().merge({ :ptpengine_hardware_timestamping => false, })
      end
      it "should have hardware specific servo KP/KI values" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:kp=0\.1/)
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/servo:ki=0\.001/)
      end
    end

    context 'with clock_leap_second_handling set incorrect' do
      let(:params) do
        super().merge({ :clock_leap_second_handling => 'woof', })
      end
      it "should fail to compile" do
        expect { is_expected.to compile }.to raise_error(/must be one of/)
      end
    end

    context 'with clock_leap_second_handling=ignore' do
      let(:params) do
        super().merge({ :clock_leap_second_handling => 'ignore', })
      end
      it "should have clock_leap_second_handling set to 'ignore'" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/clock:leap_second_handling=ignore/)
      end
    end

    context 'with ptpengine_panic_mode off' do
      let(:params) do
        super().merge({ :ptpengine_panic_mode => false, })
      end
      it "should have panic mode disabled" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/ptpengine:panic_mode=n/)
      end
    end

    context 'with ptpengine_panic_mode_duration changed' do
      let(:params) do
        super().merge({ :ptpengine_panic_mode_duration => 5, })
      end
      it "should have panic mode duration as a different value" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/ptpengine:panic_mode_duration=5$/)
      end
    end

    context 'with clock_max_offset_ppm changed' do
      let(:params) do
        super().merge({ :clock_max_offset_ppm => 1000, })
      end
      it "should have clock_max_offset_ppm with a different value" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/clock:max_offset_ppm=1000$/)
      end
    end

    context 'with ptpengine_disable_bmca=y' do
      let(:params) do
        super().merge({ :ptpengine_disable_bmca => true })
      end
      it "should have ptpengine:disable_bmca set to y" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/^ptpengine:disable_bmca=y$/)
      end
    end

    context 'with ptpengine_disable_bmca=y' do
      let(:params) do
        super().merge({ :global_cpuaffinity_cpucore => 1 })
      end
      it "should have global:cpuaffinity_cpucore=1" do
        is_expected.to contain_file('/etc/ptpd.conf').with_content(/^global:cpuaffinity_cpucore=1$/)
      end
    end
  end

  context 'multi-instance with no explicit ptpengine_interface set' do
    let (:name) { 'eth3' }
    let (:title) { 'eth3' }
    let(:params) {{
      :single_instance => false,
    }}
    it "should have ptpengine_interface set to same as namevar" do
      is_expected.to contain_file('/etc/ptpd.eth3.conf').with_content(/^ptpengine:interface=eth3$/)
    end
  end
end
