#
# An example profile for CockroachDB Validations
#

class profile::crdb{
  # Define the log file path
  $log_file = '/var/log/validation_report.log'

  # Define an exec resource to log the validation output
  exec { 'log_validation_output':
    command => "cat $log_file",
    path    => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  # Check if utilities like netstat, expect are installed on the host
  package { ['netstat', 'expect']:
    ensure => present,
    loglevel => 'debug',
    logoutput => true,
    notify => Exec['log_validation_output'],
  }

  # Check the specified ports using the netstat utility
  exec { 'check_ports':
    command => "
      if ! netstat -antp | grep -E '(22|111|2049|1110|54043|54044|54045|26257|26258|26259|8080|8081|8082)'; then
        echo 'Required ports are not open'
        exit 1
      fi
    ",
    path    => ['/bin', '/usr/bin'],
    returns => [0, 1],
    loglevel => 'debug',
    logoutput => true,
    notify => Exec['log_validation_output'],
  }

  # Check if the toolkit directory "/home/delphix/toolkit" is installed
  file { '/home/delphix/toolkit':
    ensure => 'directory',
    size   => '2 GB',
    loglevel => 'debug',
    logoutput => true,
    notify => Exec['log_validation_output'],
  }

  # Check if the Cockroach installation directory path "/u01/cockroach" is installed
  file { '/u01/cockroach':
    ensure => 'directory',
    loglevel => 'debug',
    logoutput => true,
    notify => Exec['log_validation_output'],
  }

  # Check if the delphix user has access on the cockroachdb binaries directory
  file { '/u01/cockroach':
    ensure => 'directory',
    owner  => 'delphix',
    group  => 'delphix',
    mode   => '0755',
  }

  # Check if cockroachdb binaries are installed, if not install using wget the latest stable version
  exec { 'install_cockroachdb':
    command => "
      if ! command -v cockroach &> /dev/null; then
        wget -q https://binaries.cockroachdb.com/cockroach-v22.2.8.linux-amd64.tgz
        tar xzf cockroach-v22.2.8.linux-amd64.tgz
        sudo cp -i cockroach-v22.2.8.linux-amd64/cockroach /u01/cockroach
      fi
    ",
    path    => ['/bin', '/usr/bin', '/u01/cockroach'],
    unless  => "command -v cockroach",
  }

  # Check the version of installed cockroachdb
  exec { 'check_cockroachdb_version':
    command => "cockroach version",
    path    => ['/bin', '/usr/bin', '/u01/cockroach'],
    onlyif  => "command -v cockroach",
    logoutput => true,
  }
}
