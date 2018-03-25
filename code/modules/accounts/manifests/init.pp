class accounts {

 $rootgroup = $osfamily ? {
    'Debian'  => 'sudo',
    'RedHat'  => 'wheel',
    default   => warning('This distribution is not supported by the Accounts module'),
  }
  package { 'sudo':
    ensure => installed,
	}

  user { 'ops':
    ensure      => present,
    home        => '/home/ops',
    shell       => '/bin/bash',
    managehome  => true,
    gid         => 'username',
	groups      => "$rootgroup",
	password    => '$1$T4Cr.OZ.$rRAWVd8DVK4WKIcqOHz36.',
    }

}