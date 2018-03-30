class { '::mysql::server':
   root_password           => '*BB46AE99452DD250C5A791F16CDD15AC36F1993A',#523
   remove_default_accounts => true,
   override_options        => {
   mysqld => { bind-address => '0.0.0.0'} #Allow remote connections
  }
 }

 mysql::db { 'app_db':
  user => 'dbuser',
  password => '*23AE809DDACAF96AF0FD78ED04B6A265E05AA257',
  host => '%',
  }
