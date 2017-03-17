define ptpd::instance(
  $single_instance                     = true,
  $ptpengine_interface                 = undef,
  $ptpengine_domain                    = 0,
  $ptpengine_preset                    = 'slaveonly',
  $ptpengine_hardware_timestamping     = true,
  $ptpengine_delay_mechanism           = 'E2E',
  $ptpengine_ip_mode                   = 'hybrid',
  $ptpengine_panic_mode                = 'y',
  $ptpengine_panic_mode_duration       = 30,
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
  $clock_extra_clocks                  = undef,
  $log_statistics                      = true,
  $manage_logrotate                    = true,
  $logrotate_rotate_every              = 'day',
  $logrotate_rotate                    = '7',
  $conf_file                           = '/etc/ptpd.conf',
  $logrotate_rule_name                 = 'ptpd',
  $global_log_file                     = '/var/log/ptpd.log',
  $global_statistics_file              = '/var/log/ptpd.stats',
  $global_lock_file                    = '/var/run/ptpd.lock',
  $global_status_file                  = '/var/run/ptpd.status',
) {
  if ($single_instance) {
    $real_conf_file              = $conf_file
    $real_logrotate_rule_name    = $logrotate_rule_name
    $real_global_log_file        = $global_log_file
    $real_global_statistics_file = $global_statistics_file
    $real_global_lock_file       = $global_lock_file
    $real_global_status_file     = $global_status_file
  } else {
    $real_conf_file              = "/etc/ptpd.${name}.conf"
    $real_logrotate_rule_name    = "ptpd.${name}"
    $real_global_log_file        = "/var/log/ptpd.${name}.log"
    $real_global_statistics_file = "/var/log/ptpd.${name}.stats"
    $real_global_lock_file       = "/var/run/ptpd.${name}.lock"
    $real_global_status_file     = "/var/run/ptpd.${name}.status"
  }

  $servo_kp_sw_default = 0.1
  $servo_ki_sw_default = 0.001
  $servo_kp_hw_default = 0.7
  $servo_ki_hw_default = 0.3
  $servo_adev_locked_threshold_low_hw_default = '50.000000'
  $servo_adev_locked_threshold_high_hw_default = '500.000000'
  $servo_adev_locked_threshold_low_default = '200.000000'
  $servo_adev_locked_threshold_high_default = '2000.000000'
  #$clock_max_offset_ppm_default = '500'
  #$clock_max_offset_ppm_hardware_default = '2000'

  if ($ptpengine_interface == undef) {
    fail("Must specify parameter 'ptpengine_interface' when ptpd service is configured to run")
  }
  validate_integer($ptpengine_domain)
  $ptpengine_hardware_timestamping_bool = str2bool($ptpengine_hardware_timestamping)
  validate_bool($ptpengine_hardware_timestamping_bool)
  $log_statistics_bool = str2bool($log_statistics)
  validate_bool($log_statistics_bool)
  if ! ($ptpengine_delay_mechanism in [ 'E2E', 'P2P' ]) {
    fail("Parameter 'ptpengine_delay_mechanism' must be on of 'E2E' or 'P2P'")
  }
  if ! ($ptpengine_ip_mode in ['multicast','hybrid','unicast']) {
    fail("Parameter 'ptpengine_ip_mode' must be one of 'multicast', 'hybrid' or 'unicast'")
  }
  if ! ($ptpengine_preset in ['slaveonly','masterslave','masteronly']) {
    fail("Parameter 'ptpengine_preset' must be one of 'slaveonly', 'masterslave' or 'masteronly'")
  }
  validate_absolute_path($real_global_log_file)
  validate_absolute_path($real_global_statistics_file)
  $ptpengine_panic_mode_bool = str2bool($ptpengine_panic_mode)
  validate_bool($ptpengine_panic_mode_bool)
  validate_integer($ptpengine_panic_mode_duration, 7200, 1)

  if ($ptpengine_hardware_timestamping_bool) {
    $real_servo_kp = pick($servo_kp, $servo_kp_hw_default)
    $real_servo_ki = pick($servo_ki, $servo_ki_hw_default)
  } else {
    $real_servo_kp = pick($servo_kp, $servo_kp_sw_default)
    $real_servo_ki = pick($servo_ki, $servo_ki_sw_default)
  }
  $real_servo_kp_hardware = pick($servo_kp_hardware, $servo_kp_hw_default)
  $real_servo_ki_hardware = pick($servo_ki_hardware, $servo_ki_hw_default)

  if ! ($clock_leap_second_handling in ['accept', 'ignore', 'step', 'smear']) {
    fail("Parameter 'clock_leap_second_handling' must be one of 'accept', 'ignore', 'step', or 'smear'")
  }
  validate_integer($clock_max_offset_ppm, 1000, 500)

  $real_servo_adev_locked_threshold_low = pick($servo_adev_locked_threshold_low, $servo_adev_locked_threshold_low_default)
  $real_servo_adev_locked_threshold_high = pick($servo_adev_locked_threshold_high, $servo_adev_locked_threshold_high_default)
  $real_servo_adev_locked_threshold_low_hw = pick($servo_adev_locked_threshold_low_hw, $servo_adev_locked_threshold_low_hw_default)
  $real_servo_adev_locked_threshold_high_hw = pick($servo_adev_locked_threshold_high_hw, $servo_adev_locked_threshold_high_hw_default)

  file { $real_conf_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/ptpd.conf.erb"),
    require => Package[$::ptpd::package_name],
    notify  => Service[$::ptpd::service_name],
  }

  if ($manage_logrotate) {
    logrotate::rule { $logrotate_rule_name:
      path          => "${real_global_log_file} ${real_global_statistics_file}",
      compress      => true,
      delaycompress => true,
      copytruncate  => true,
      missingok     => true,
      rotate_every  => $logrotate_rotate_every,
      rotate        => $logrotate_rotate,
      postrotate    => "/bin/kill -HUP $(cat ${global_lock_file} 2>/dev/null) 2> /dev/null || true",
    }
  }
}
