node db{ 
include '::mysql-core::'
}

node db-slave{

include '::mysql-slave::slave'

}
