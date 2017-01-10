# Class: ptpd, see README.md for documentation
class ptpd(
  $ptpengine_interface                 = undef,
  $ptpengine_domain                    = 0,
  $ptpengine_preset                    = 'slaveonly',
  $ptpengine_hardware_timestamping     = true,
  $ptpengine_delay_mechanism           = 'E2E',
  $ptpengine_ip_mode                   = 'hybrid',
  $ptpengine_panic_mode                = 'y',
  $ptpengine_panic_mode_duration       = 30,
  $servo_adev_locked_threshold_low_hw  = '50.000000',
  $servo_adev_locked_threshold_high_hw = '500.000000',
  $servo_kp                            = undef,
  $servo_ki                            = undef,
  $clock_leap_second_handling          = 'accept',
  $clock_max_offset_ppm                = 500,
  $global_log_file                     = '/var/log/ptpd.log',
  $log_statistics                      = true,
  $global_statistics_file              = '/var/log/ptpd.stats',
  $global_lock_file                    = '/var/run/ptpd.lock',
  $global_status_file                  = '/var/run/ptpd.status',
  $package_name                        = 'ptpd-linuxphc',
  $service_name                        = 'ptpd',
  $service_ensure                      = 'running',
  $service_enable                      = true,
  $manage_logrotate                    = true,
  $logrotate_rotate_every              = 'day',
  $logrotate_rotate                    = '7',
) {
  $servo_kp_sw_default = 0.1
  $servo_ki_sw_default = 0.001
  $servo_kp_hw_default = 0.7
  $servo_ki_hw_default = 0.3

  #FIXME there's certain bits of validation we don't want to bother doing
  #if we don't actually plan on running PTPd (turning it off)
  if ($service_ensure == 'running' and $ptpengine_interface == undef) {
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
  validate_absolute_path($global_log_file)
  validate_absolute_path($global_statistics_file)
  validate_string($package_name)
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

  if ! ($clock_leap_second_handling in ['accept', 'ignore', 'step', 'smear']) {
    fail("Parameter 'clock_leap_second_handling' must be one of 'accept', 'ignore', 'step', or 'smear'")
  }
  validate_integer($clock_max_offset_ppm, 1000, 500)

  package { $package_name:
    ensure => present,
  }

  $conf_file = '/etc/ptpd.conf'
  file { $conf_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/ptpd.conf.erb"),
    require => Package[$package_name],
    notify  => Service[$service_name],
  }

  $sysconf_file = '/etc/sysconfig/ptpd'
  file { $sysconf_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/ptpd_sysconfig.erb"),
    require => Package[$package_name],
    notify  => Service[$service_name],
  }

  service { $service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => true,
    hasrestart => true,
    require    => File[$conf_file],
  }

  if ($manage_logrotate) {
    logrotate::rule { 'ptpd':
      path          => "${global_log_file} ${global_statistics_file}",
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
