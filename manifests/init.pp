# Class: ptpd, see README.md for documentation
class ptpd(
  $single_instance                     = true,
  $ptpengine_interface                 = undef,
  $ptpengine_domain                    = 0,
  $ptpengine_preset                    = 'slaveonly',
  $ptpengine_hardware_timestamping     = true,
  $ptpengine_delay_mechanism           = 'E2E',
  $ptpengine_mode                      = 'hybrid',
  $ptpengine_panic_mode                = true,
  $ptpengine_panic_mode_duration       = 30,
  $ptpengine_disable_bmca              = false,
  $ptpengine_log_sync_interval         = 0,
  $ptpengine_timing_acl_order          = undef,
  $ptpengine_timing_acl_permit         = undef,
  $ptpengine_timing_acl_deny           = undef,
  $servo_adev_locked_threshold_low_hw  = undef,
  $servo_adev_locked_threshold_high_hw = undef,
  $servo_adev_locked_threshold_low     = undef,
  $servo_adev_locked_threshold_high    = undef,
  $servo_kp                            = undef,
  $servo_ki                            = undef,
  $servo_kp_hardware                   = undef,
  $servo_ki_hardware                   = undef,
  $clock_leap_second_handling          = 'accept',
  $clock_max_offset_ppm                = '500',
  $clock_max_offset_ppm_hardware       = '2000',
  $clock_master_clock_name             = undef,
  $clock_disabled_clock_names          = undef,
  $clock_readonly_clock_names          = undef,
  $clock_extra_clocks                  = undef,
  $log_statistics                      = true,
  $manage_logrotate                    = true,
  $logrotate_rotate_every              = 'day',
  $logrotate_rotate                    = '7',
  $conf_file                           = '/etc/ptpd.conf',
  $global_log_file                     = '/var/log/ptpd.log',
  $global_statistics_file              = '/var/log/ptpd.stats',
  $global_lock_file                    = '/var/run/ptpd.lock',
  $global_status_file                  = '/var/run/ptpd.status',
  $global_log_json                     = false,
  $global_json_file                    = '/var/run/ptpd.json',
  $global_cpuaffinity_cpucore          = 0,
  $conf_file_ensure                    = 'file',
  $package_name                        = 'ptpd-libcck',
  $package_ensure                      = 'present',
  $service_name                        = 'ptpd',
  $service_ensure                      = 'running',
  $service_enable                      = true,
) {
  validate_string($package_name)

  package { $package_name:
    ensure  => $package_ensure,
  }

  #LB: if this is a single instance, manage the service as a Puppet service and
  #create a standard configuration file.
  if ($single_instance) {
    if ($conf_file_ensure == 'absent') {
      $file_requires = Service[$service_name]
      $file_notifies = undef
    } else {
      $file_requires = Package[$package_name]
      $file_notifies = Service[$service_name]
    }

    ptpd::instance { 'ptpd':
      single_instance                     => $single_instance,
      ptpengine_interface                 => $ptpengine_interface,
      ptpengine_domain                    => $ptpengine_domain,
      ptpengine_preset                    => $ptpengine_preset,
      ptpengine_hardware_timestamping     => $ptpengine_hardware_timestamping,
      ptpengine_delay_mechanism           => $ptpengine_delay_mechanism,
      ptpengine_mode                      => $ptpengine_mode,
      ptpengine_panic_mode                => $ptpengine_panic_mode,
      ptpengine_panic_mode_duration       => $ptpengine_panic_mode_duration,
      ptpengine_disable_bmca              => $ptpengine_disable_bmca,
      ptpengine_log_sync_interval         => $ptpengine_log_sync_interval,
      ptpengine_timing_acl_order          => $ptpengine_timing_acl_order,
      ptpengine_timing_acl_permit         => $ptpengine_timing_acl_permit,
      ptpengine_timing_acl_deny           => $ptpengine_timing_acl_deny,
      servo_adev_locked_threshold_low_hw  => $servo_adev_locked_threshold_low_hw,
      servo_adev_locked_threshold_high_hw => $servo_adev_locked_threshold_high_hw,
      servo_adev_locked_threshold_low     => $servo_adev_locked_threshold_low,
      servo_adev_locked_threshold_high    => $servo_adev_locked_threshold_high,
      servo_kp                            => $servo_kp,
      servo_ki                            => $servo_ki,
      servo_kp_hardware                   => $servo_kp_hardware,
      servo_ki_hardware                   => $servo_ki_hardware,
      clock_leap_second_handling          => $clock_leap_second_handling,
      clock_max_offset_ppm                => $clock_max_offset_ppm,
      clock_max_offset_ppm_hardware       => $clock_max_offset_ppm_hardware,
      clock_master_clock_name             => $clock_master_clock_name,
      clock_disabled_clock_names          => $clock_disabled_clock_names,
      clock_readonly_clock_names          => $clock_readonly_clock_names,
      clock_extra_clocks                  => $clock_extra_clocks,
      log_statistics                      => $log_statistics,
      manage_logrotate                    => $manage_logrotate,
      logrotate_rotate_every              => $logrotate_rotate_every,
      logrotate_rotate                    => $logrotate_rotate,
      conf_file                           => $conf_file,
      global_log_file                     => $global_log_file,
      global_statistics_file              => $global_statistics_file,
      global_lock_file                    => $global_lock_file,
      global_status_file                  => $global_status_file,
      global_log_json                     => $global_log_json,
      global_json_file                    => $global_json_file,
      global_cpuaffinity_cpucore          => $global_cpuaffinity_cpucore,
      conf_file_ensure                    => $conf_file_ensure,
      conf_file_requires                  => $file_requires,
      conf_file_notifies                  => $file_notifies,
    }

    #LB: the sysconfig file is only useful if running as a single instance. If
    #running multiple instances, you need to pass the same environment variables to
    #the PTP daemon yourself, eg: use Supervisord ENV vars, or pass the right command
    #line arguments to the PTP daemon just like the Init script does.
    $sysconf_file = '/etc/sysconfig/ptpd'
    file { $sysconf_file:
      ensure  => $conf_file_ensure,
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/ptpd_sysconfig.erb"),
      require => $file_requires,
      notify  => $file_notifies,
    }

    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  } else {
    #If we are in multi-instance mode, ensure the main config file doesn't exist otherwise
    #it might conflict with other ptpd daemons if it is accidentally started.
    file { $conf_file:
      ensure => absent,
    }
  }
}
