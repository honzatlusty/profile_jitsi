#class profile_jitsi::nginx
class profile_jitsi::nginx (
  $jitsi_vhost_server_name
  
) {

$proxy_headers = [
    'X-Forwarded-For $remote_addr',
    'Host $http_host',
  ]
  class {'::nginx': }



#  temp. fix https://github.com/jfryman/puppet-nginx/issues/610
  file {'/etc/nginx/sites-avalable':
    ensure => 'directory'
  } ->

  nginx::resource::vhost { $jitsi_vhost_server_name:
    listen_port         => 80,
    index_files         => [ 'index.html' ],
    vhost_cfg_append    => {
      root => '/usr/share/jitsi-meet/',
    },
    location_custom_cfg => {
      ssi => 'on',
    },
    require             => Package['nginx'],
  }

  nginx::resource::location { '~ ^/([a-zA-Z0-9=\?]+)$':
      ensure              => present,
      vhost               => $jitsi_vhost_server_name,
      location_custom_cfg => {
        rewrite => ['^/(.*)$ / break'],
      },
  }

  nginx::resource::location { '/http-bind':
      ensure              => present,
      vhost               => $jitsi_vhost_server_name,
      location_custom_cfg => {
        proxy_pass       => 'http://localhost:5280/http-bind',
        proxy_set_header => $proxy_headers,
      },
  }
#  ::rsyslog::shiplog{'jitsi-nginx-access-log':
#    filename     => "/var/log/nginx/${jitsi_vhost_server_name}.access.log",
#    inputfiletag => 'nginx-access',
#    facility     => 'DAEMON',
#  }

#  ::rsyslog::shiplog{'jitsi-nginx-error-log':
#    filename     => "/var/log/nginx/${jitsi_vhost_server_name}.error.log",
#    inputfiletag => 'nginx-error',
#    facility     => 'DAEMON',
#  }
}
