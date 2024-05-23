class profile::crdb {
  # Define the log file path
  $log_file = '/var/log/crdb_env_log_validation_output.log'

  # Check if utilities like netstat, expect are installed on the host
  package { ['netstat', 'expect']:
    ensure     => present,
    notify     => Exec['check_ports'],
    logoutput  => $log_file,
  }

  # Check the specified ports using the netstat utility
  exec { 'check_ports':
    command   => "
      if ! netstat -antp | grep -E '(22|111|2049|1110|54043|54044|54045|26257|26258|26259|8080|8081|8082)' >> $log_file; then
        echo 'Required ports are not open' >> $log_file
        exit 1
      fi
    ",
    path      => ['/bin', '/usr/bin'],
    returns   => [0, 1],
    logoutput => $log_file,
  }

  # Check if the toolkit directory "/home/delphix/toolkit" is installed
  file { '/home/delphix/toolkit':
    ensure     => 'directory',
    logoutput  => $log_file,
  }

  # Check if the delphix user exists
  exec { 'check_delphix_user':
    command   => "id delphix",
    path      => ['/bin', '/usr/bin'],
    logoutput => $log_file,
  }

  # Check if the delphix user has access on the cockroachdb binaries directory
  exec { 'check_delphix_access':
    command => "ls -ld /u01/cockroach",
    path    => ['/bin', '/usr/bin'],
    onlyif  => "id delphix",
    logoutput => $log_file,
  }

  # Check if the delphix user has access on the cockroachdb binaries directory
  file { '/u01/cockroach':
    ensure     => 'directory',
    owner      => 'delphix',
    group      => 'delphix',
    mode       => '0755',
    logoutput  => $log_file,
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
    logoutput => $log_file,
  }

  # Check the version of installed cockroachdb
  exec { 'check_cockroachdb_version':
    command   => "cockroach version",
    path      => ['/bin', '/usr/bin', '/u01/cockroach'],
    onlyif    => "command -v cockroach",
    logoutput => $log_file,
  }
}

