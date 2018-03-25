class { '::mysql::server':
   root_password           => '123',
   remove_default_accounts => true,
   override_options        => {
    mysqld => { bind-address => '0.0.0.0'} #Allow remote connections
  }
 }

 mysql::db { 'app_db':
  user => 'dbuser',
  password => '123',
  host => '%',
  }