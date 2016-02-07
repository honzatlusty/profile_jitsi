class profile_jitsi (
  $bosh,
  $jicofo_configuration,
  $jicofo_password,
  $jitsi_videobridge_configuration,
  $jitsi_vhost_server_name,
  $nat_harvester_local_address  = undef,
  $nat_harvester_public_address = undef,
  $tcp_harvester_port           = undef,
  $user_name,
  $user_password,
  $videobridge_password,
  $ssl_key                      = undef,
  $ssl_cert                     = undef,
  $country,
  $company,
  $jitsi_domain,
  $prosody_interface,
#  $hypervisor_public_interface,
) {
  class{profile_jitsi::nginx:
    jitsi_vhost_server_name => $jitsi_vhost_server_name,
  }

  class{profile_jitsi::prosody:
    jicofo_password         =>  $jicofo_password,
    jitsi_vhost_server_name =>  $jitsi_vhost_server_name,
    user_name               =>  $user_name,
    user_password           =>  $user_password,
    videobridge_password    =>  $videobridge_password,
    ssl_key                 =>  $ssl_key,
    ssl_cert                =>  $ssl_cert,
    country                 =>  $country,
    company                 =>  $company,
    jitsi_domain            =>  $jitsi_domain,
    prosody_interface       =>  $prosody_interface,
  }


  class {jitsi:
    bosh                             => $bosh,
    jicofo_configuration             => $jicofo_configuration,
    jitsi_vhost_server_name          => $jitsi_vhost_server_name,
    jitsi_videobridge_configuration  => $jitsi_videobridge_configuration,
  }

}
