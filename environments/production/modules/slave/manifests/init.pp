class slave {

 class { 'mysql::server':
       	restart          => true,
	root_password    => '123',
	override_options => {
	  'mysqld' => {
		'bind_address' => '0.0.0.0',
		'server-id'         => '2',
		'binlog-format'     => 'mixed',
		'log-bin'           => 'mysql-bin',
		'relay-log'         => 'mysql-relay-bin',
		'log-slave-updates' => '1',
		'read-only'         => '1',
		'replicate-do-db'   => ['app_db'],
	  },
	}
  }

  mysql::db { 'app_db':
	ensure   => 'present',
	user     => 'dbuser',
	password => '123',
	host     => '%',
	grant    => ['all'],
  }

}
