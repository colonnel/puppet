node db{ 
include 'core'
file { '/tmp/replica.sh':

 source => "puppet:///modules/core/replica.sh",
 ensure => 'file',
 owner => 'root',
 group => 'root',
 mode  => '0700',
 notify => Exec['exec_script'],
 }
 exec { 'exec_script':
  command => "/bin/bash -c '/tmp/replica.sh'",
 }

}

node db-slave{

include 'slave'

}
