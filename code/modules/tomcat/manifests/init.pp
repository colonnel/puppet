class tomcat8 {
 package { 'tomcat8':
  ensure => installed,
 }
 service { 'tomcat8':
  ensure => running,
  require => Package[tomcat8],
 }

 file { 'app4.war':
 ensure => present,
 source => 'puppet:///files/app4.war',
 path => '/var/lib/tomcat8/webapps/app4.war',
 owner => 'root',
 group => 'root',
 mode => '0644',
 }
}

