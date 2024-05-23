class profile::crdb {
  # Define the log file path
  $log_file = '/var/log/crdb_env_log_validation_output.log'

  # Check if utilities like netstat, expect are installed on the host
  package { ['net-tools', 'expect']:
    ensure => present,
    notify => Exec['check_ports'],
  }

  # Check the specified ports using the netstat utility
   exec { 'check_ports':
    command   => "/bin/bash -c 'netstat -antp | grep -E \"(22|111|2049|1110|54043|54044|54045|26257|26258|26259|8080|8081|8082)\" > $log_file || echo \"Required ports are not open\" >> $log_file'",
    path      => ['/bin', '/usr/bin'],
    returns   => [0, 1],
    logoutput => true,
  }

  # Check if the toolkit directory "/home/delphix/toolkit" is installed
  file { '/home/delphix/toolkit':
    ensure     => 'directory',
  }

  # Check if the delphix user exists
  exec { 'check_delphix_user':
    command   => "id delphix >> $log_file",
    path      => ['/bin', '/usr/bin'],
    logoutput => true,
  }

  # Check if the delphix user has access on the cockroachdb binaries directory
  exec { 'check_delphix_access':
    command => "ls -ld /u01/cockroach >> $log_file",
    path    => ['/bin', '/usr/bin'],
    onlyif  => "id delphix",
    logoutput => true,
  }

  # Check if the delphix user has access on the cockroachdb binaries directory
  file { '/u01/cockroach':
    ensure     => 'directory',
    owner      => 'delphix',
    group      => 'delphix',
    mode       => '0755',
  }

  # Check if cockroachdb binaries are installed, if not install using wget the latest stable version
  exec { 'install_cockroachdb':
    command  => "/bin/bash -c 'wget -q https://binaries.cockroachdb.com/cockroach-v22.2.8.linux-amd64.tgz >> $log_file && tar -zxvf cockroach-v22.2.8.linux-amd64.tgz >> $log_file && sudo cp -i cockroach-v22.2.8.linux-amd64/cockroach /u01/cockroach >> $log_file'",
    path     => ['/bin', '/usr/bin', '/u01/cockroach'],
    unless   => "/bin/bash -c 'command -v cockroach'",
    logoutput => true,
  }

  # Check the version of installed cockroachdb
  exec { 'check_cockroachdb_version':
    command   => "cockroach version >> $log_file",
    path      => ['/bin', '/usr/bin', '/u01/cockroach'],
    onlyif    => "command -v cockroach",
    logoutput => true,
  }

  # Create environment cockroachdb
  exec { 'create_env':
    command   => "/tmp/create_env.sh",
    path      => ['/bin', '/usr/bin', '/u01/cockroach'],
    logoutput => true,
  }
}

