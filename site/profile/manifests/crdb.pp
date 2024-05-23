# An example profile
#
class profile::crdb{
  $extract_path  = '/tmp/hyperscale_compliance_images'
  $docker_image1 = "${extract_path}/controller-service.tar"
  $docker_image2 = "${extract_path}/masking-service.tar"
  $docker_image3 = "${extract_path}/proxy.tar"
  $docker_image4 = "${extract_path}/mongo-unload-service.tar"
  $docker_image5 = "${extract_path}/mongo-load-service.tar"
  $compose_file  = "${extract_path}/docker-compose.yaml"

  # Load the Docker images
  exec { 'test_command':
    command     => "ls -lart > /tmp/ls_op",
    path        => ['/bin', '/usr/bin'],
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

