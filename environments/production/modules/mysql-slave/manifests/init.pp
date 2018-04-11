class { 'slave':
  root_password           => '123',
  remove_default_accounts => true,
  override_options        => {
    'mysqld' => {
      'server-id' => 2,
      'log_bin' => '/var/log/mysql/mysql-bin.log',
      'binlog_do_db' => 'app_db',
      'bind-address' => '0.0.0.0',
      'relay-log' => '/var/log/mysql/mysql-relay-bin.log',
      'replicate-do-db' => 'app_db',
    }
  },
  databases => {
    'app_db' => {
      charset  => 'utf8',
      collate  => 'utf8_swedish_ci',
    }
  },
  users => {
    'dbuser@%' => {
      ensure                   => 'present',
      max_connections_per_hour => '0',
      max_queries_per_hour     => '0',
      max_updates_per_hour     => '0',
      max_user_connections     => '0',
      password_hash            => '*23AE809DDACAF96AF0FD78ED04B6A265E05AA257', # PASSWORD('123')
    },
    'slave_user@%' => {
      ensure                   => 'present',
      max_connections_per_hour => '0',
      max_queries_per_hour     => '0',
      max_updates_per_hour     => '0',
      max_user_connections     => '0',
      password_hash            => '*23AE809DDACAF96AF0FD78ED04B6A265E05AA257', # PASSWORD('123')
    },
  },
  grants => {
    'dbuser@%/app_db.*' => {
      ensure     => 'present',
      options    => ['GRANT'],
      privileges => ['ALL'],
      table      => 'mydb.*',
      user       => 'dbuser@%',
    },
    'slave_user@%/*.*' => {
      ensure     => 'present',
      options    => ['GRANT'],
      privileges => ['REPLICATION SLAVE'],
      table      => '*.*',
      user       => 'slave_user@%',
    },
  }
}


