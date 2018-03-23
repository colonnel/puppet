class jenkins {
 
  exec { 'install_jenkins_package_keys':class jenkins {
 
  exec { 'install_jenkins_package_keys':
    command => '/usr/bin/wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | /usr/bin/apt-key add - ',
  }
 
  file { "/etc/apt/sources.list.d/jenkins.list":
      mode => 644,
     owner => root,
     group => root,
    source => "puppet:///modules/jenkins/etc/apt/sources.list.d/jenkins.list",
  }
 
  package { 'jenkins':
      ensure => latest,
    require  => [ Exec['install_jenkins_package_keys'],
                  File['/etc/apt/sources.list.d/jenkins.list'], ],
  }
 
  service { 'jenkins':
    ensure => running,
  }
 
}