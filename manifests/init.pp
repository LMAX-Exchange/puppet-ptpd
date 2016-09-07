# Class: ptpd, see README.md for documentation
class ptpd(
  $ptpengine_interface             = undef,
  $ptpengine_domain                = 0,
  $ptpengine_preset                = 'slaveonly',
  $ptpengine_hardware_timestamping = true,
  $ptpengine_delay_mechanism       = 'E2E',
  $ptpengine_ip_mode               = 'hybrid',
  $global_log_file                 = '/var/log/ptpd.log',
  $global_statistics_file          = '/var/log/ptpd.stats',
  $global_lock_file                = '/var/run/ptpd.lock',
  $global_status_file              = '/var/run/ptpd.status',
  $package_name                    = 'ptpd-linuxphc',
  $service_name                    = 'ptpd',
  $service_ensure                  = 'running',
  $service_enable                  = true,
  $manage_logrotate                = true,
) {
  #FIXME there's certain bits of validation we don't want to bother doing
  #if we don't actually plan on running PTPd (turning it off)
  if ($service_ensure == 'running' and $ptpengine_interface == undef) {
    fail("Must specify parameter 'ptpengine_interface' when ptpd service is configured to run")
  }
  validate_integer($ptpengine_domain)
  $ptpengine_hardware_timestamping_bool = str2bool($ptpengine_hardware_timestamping)
  validate_bool($ptpengine_hardware_timestamping_bool)
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
      rotate_every  => 'day',
      rotate        => '7',
      postrotate    => "/bin/kill -HUP $(cat ${global_lock_file} 2>/dev/null) 2> /dev/null || true",
    }
  }
}
