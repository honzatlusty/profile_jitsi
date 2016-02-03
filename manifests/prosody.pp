class profile_jitsi::prosody (
  $jicofo_password,
  $jitsi_vhost_server_name,
  $user_name,
  $user_password,
  $videobridge_password,
  $ssl_key,
  $ssl_cert,
  $country,
  $company,
  $jitsi_domain,
  $prosody_interface,

) {
  package { 'prosody':
    ensure => 'present',
  }

  service { 'prosody':
    ensure => 'running',
  }

  exec { 'prosodyctl cert generate domain':
      command => "printf \"2048\n${country}\n.\n${company}\n.\n${jitsi_domain}\n.\" | prosodyctl cert generate ${jitsi_domain}",
      unless  => "cd /var/lib/prosody/ && find ${jitsi_domain}.cnf  ${jitsi_domain}.crt  ${jitsi_domain}.key",
      path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
      notify  => Service['prosody'],
      require => Package['prosody'],
    }

      ##prosody stores user data in /var/lib/prosody/${jitsi_domain}/accunts/${user}.dat where ${jitsi_domain} has its non-alphanumeric
      ##chars ('.' and  '-') translated into the corresponding ascii codes, so we need to adjust the path too.
      ##I was not able to create a prosody vhost with other non-alphanumeric characters than those two, prosody crashed, so I only
      ##care about them. 

  exec { 'prosodyctl register user auth.domain user_password':
      command => "prosodyctl register ${user_name} auth.${jitsi_domain} ${user_password}",
      unless  => "find  $(echo -n /var/lib/prosody/auth.${jitsi_domain} | sed 's?\\.?%2e?g' | sed 's?-?%2d?g')/accounts/${user_name}.dat",
      path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
      require => Package['prosody'],
      notify  => Service['prosody'],
    }

  file { '/etc/prosody/prosody.cfg.lua':
    ensure  => present,
    content => template('profile_jitsi/prosody.cfg.lua.erb'),
    require => Package['prosody'],
    notify  => Service['prosody'],
  }

  file { "/etc/prosody/conf.d/${jitsi_domain}.cfg.lua":
    ensure  => present,
    content => template('profile_jitsi/jitsi.cfg.lua.erb'),
    require => Package['prosody'],
    notify  => Service['prosody'],
  }

  $auth_dir = inline_template("<%= ('auth.' + @jitsi_domain).gsub('.', '%2e').gsub('-', '%2d') %>")

  file { "/var/lib/prosody/${auth_dir}/accounts/${user_name}.dat":
    ensure  => present,
    content => template('profile_jitsi/user.dat.erb'),
    notify  => Service['prosody'],
    require => Package['prosody'],
  }

}
