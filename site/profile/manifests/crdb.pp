#
# An example profile for CockroachDB Validations
#

class profile::crdb{
  # Check if the toolkit directory "/home/delphix/toolkit" is installed
  file { '/home/delphix/toolkit':
    ensure => 'directory',
  }

  # Check if the Cockroach installation directory path "/u01/cockroach" is installed
  file { '/u01/cockroach':
    ensure => 'directory',
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

  # Verify the specified ports on the hosts
  firewall::openport { 'allow_ssh':
    port => 22,
  }

  firewall::openport { 'allow_rpc':
    port => [111, 2049, 54043, 54044, 54045, 26257, 26258, 26258],
  }

  firewall::openport { 'allow_nsmclient':
    port => 1110,
  }

  firewall::openport { 'allow_traceroute':
    port => '33434-33464/udp',
  }

  ## Ensure the directory for extraction exists
  #file { $extract_path:
  #  ensure => directory,
  #}

  ## Download and extract the tar file
  #archive { $tar_dest:
  #  ensure       => present,
  #  source       => $tar_url,
  #  extract      => true,
  #  extract_path => $extract_path,
  #  creates      => $docker_image1,
  #  cleanup      => true,
  #  require      => File[$extract_path],
  #}

  ## Load the Docker images
  #exec { 'load_controller_service_image':
  #  command     => "docker load -i ${docker_image1}",
  #  path        => ['/bin', '/usr/bin'],
  #  #refreshonly => true,
  #  subscribe   => Archive[$tar_dest],
  #}

  #exec { 'load_masking_service_image':
  #  command     => "docker load -i ${docker_image2}",
  #  path        => ['/bin', '/usr/bin'],
  #  #refreshonly => true,
  #  subscribe   => Archive[$tar_dest],
  #}

  #exec { 'load_proxy_service_image':
  #  command     => "docker load -i ${docker_image3}",
  #  path        => ['/bin', '/usr/bin'],
  #  #refreshonly => true,
  #  subscribe   => Archive[$tar_dest],
  #}

  #exec { 'load_mongo_unload_service_image':
  #  command     => "docker load -i ${docker_image4}",
  #  path        => ['/bin', '/usr/bin'],
  #  #refreshonly => true,
  #  subscribe   => Archive[$tar_dest],
  #}

  #exec { 'load_mongo_load_service_image':
  #  command     => "docker load -i ${docker_image5}",
  #  path        => ['/bin', '/usr/bin'],
  #  #refreshonly => true,
  #  subscribe   => Archive[$tar_dest],
  #}

  ## Run docker-compose up -d
  #exec { 'docker_compose_up':
  #  command     => "docker-compose -f ${compose_file} up -d",
  #  path        => ['/bin', '/usr/bin', '/usr/local/bin'],
  #  cwd         => $extract_path, # Ensure the command runs in the directory with the docker-compose.yml file
  #  #refreshonly => true,
  #  subscribe   => [Exec['load_mongo_load_service_image'], Exec['load_mongo_unload_service_image'], Exec['load_proxy_service_image'], Exec['load_masking_service_image'], Exec['load_controller_service_image']],
  #}
}

