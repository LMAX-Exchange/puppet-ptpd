# Class: ptpd, see README.md for documentation
class ptpd(
  $ptpengine_interface,
  $ptpengine_domain                = 0,
  $ptpengine_hardware_timestamping = 'y',
  $ptpengine_delay_mechanism       = 'E2E',
  $ptpengine_ip_mode               = 'hybrid',
  $global_log_file                 = '/var/log/ptpd.log',
  $global_statistics_file          = '/var/log/ptpd.stats',
  $package_name                    = 'ptpd-linuxphc',
) {
  validate_string($ptpengine_interface)
  validate_integer($ptpengine_domain)
  $ptpengine_hardware_timestamping_bool = str2bool($ptpengine_hardware_timestamping)
  validate_bool($ptpengine_hardware_timestamping_bool)
  if ! ($ptpengine_delay_mechanism in [ 'E2E', 'P2P' ]) {
    fail("Parameter 'ptpengine_delay_mechanism' must be on of 'E2E' or 'P2P'")
  }
  if ! ($ptpengine_ip_mode in ['hybrid','unicast']) {
     fail("Parameter 'ptpengine_ip_mode' must be one of 'hybrid' or 'unicast'")
  }
  validate_absolute_path($global_log_file)
  validate_absolute_path($global_statistics_file)
  validate_string($package_name)

  package { $package_name:
    ensure => present,
  }

  file { '/etc/ptpd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/ptpd.conf.erb"),
  }

  service { 'ptpd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  #TODO logrotate
}
