class core {

 class { '::mysql::server':
    root_password           => '123',
    remove_default_accounts => true,
    override_options        => {
    mysqld => { 
     bind-address => '0.0.0.0',
     'server-id'                      => '1',
     'binlog-format'                  => 'mixed',
     'log-bin'                        => 'mysql-bin',
     'datadir'                        => '/var/lib/mysql',
     'innodb_flush_log_at_trx_commit' => '1',
     'sync_binlog'                    => '1',
     'binlog-do-db'                   => ['app_db'],
   

   },
  }
 }


 mysql_user { 'slave_user@%':
    ensure        => 'present',
    password_hash => mysql_password('123'),
    }


 mysql_grant { 'slave_user@%/*.*':
    ensure     => 'present',
    privileges => ['REPLICATION SLAVE'],
    table      => '*.*',
    user       => 'slave_user@%',
    }


 mysql::db { 'app_db':
  user => 'dbuser',
  password => '123',
  host => '%',
  }

}
