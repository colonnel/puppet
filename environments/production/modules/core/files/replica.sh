#!/bin/bash

DB=app_db
DUMP_FILE="/tmp/$DB-export-$(date +"%Y%m%d%H%M%S").sql"

USER=root
PASS=123

DBUSER=root
DBPASS=123

RUSER=slave_user
RPASS=123

MASTER_HOST=192.168.174.151
SLAVE_HOSTS=(192.168.174.154)

##
# MASTER
# ------
# Export database and read log position from master, while locked
##

echo "MASTER: $MASTER_HOST"

mysql "-u$DBUSER" "-p$DBPASS" $DB <<-EOSQL &
	GRANT REPLICATION SLAVE ON *.* TO '$DBUSER'@'%' IDENTIFIED BY '$DBPASS';
	FLUSH PRIVILEGES;
	FLUSH TABLES WITH READ LOCK;
	DO SLEEP(3600);
EOSQL

echo "  - Waiting for database to be locked"
sleep 3

# Dump the database (to the client executing this script) while it is locked
echo "  - Dumping database to $DUMP_FILE"
mysqldump -h 127.0.0.1 "-u$DBUSER" "-p$DBPASS" --opt $DB > $DUMP_FILE
echo "  - Dump complete."

# Take note of the master log position at the time of dump
MASTER_STATUS=$(mysql -h 127.0.0.1 "-u$DBUSER" "-p$DBPASS" -ANe "SHOW MASTER STATUS;" | awk '{print $1 " " $2}')
LOG_FILE=$(echo $MASTER_STATUS | cut -f1 -d ' ')
LOG_POS=$(echo $MASTER_STATUS | cut -f2 -d ' ')
echo "  - Current log file is $LOG_FILE and log position is $LOG_POS"

# When finished, kill the background locking command to unlock
kill $! 2>/dev/null
wait $! 2>/dev/null

echo "  - Master database unlocked"
##
# SLAVES
# ------
# Import the dump into slaves and activate replication with
# binary log file and log position obtained from master.
##

for SLAVE_HOST in "${SLAVE_HOSTS[@]}"
do
	echo "SLAVE: $SLAVE_HOST"
	echo "  - Creating database copy"
	mysql -h $SLAVE_HOST "-u$DBUSER" "-p$DBPASS" -e "DROP DATABASE IF EXISTS $DB; CREATE DATABASE $DB;"
	sudo -u dravig  scp $DUMP_FILE $SLAVE_HOST:$DUMP_FILE >/dev/null
	mysql -h $SLAVE_HOST "-u$DBUSER" "-p$DBPASS" $DB < $DUMP_FILE

	echo "  - Setting up slave replication"
	mysql -h $SLAVE_HOST "-u$DBUSER" "-p$DBPASS" $DB <<-EOSQL &
		STOP SLAVE;
		#CHANGE MASTER TO MASTER_HOST="192.168.174.151",
		#MASTER_USER='$DBUSER',
		#MASTER_PASSWORD='$DBPASS',
		#MASTER_LOG_FILE='$LOG_FILE',
		#MASTER_LOG_POS=$LOG_POS;
		CHANGE MASTER TO MASTER_HOST='192.168.174.151',MASTER_USER='slave_user', MASTER_PASSWORD='123', MASTER_LOG_FILE='$LOG_FILE', MASTER_LOG_POS=$LOG_POS;
		START SLAVE;
	EOSQL
	# Wait for slave to get started and have the correct status
	sleep 2
	# Check if replication status is OK
	SLAVE_OK=$(mysql -h $SLAVE_HOST "-u$DBUSER" "-p$DBPASS" -e "SHOW SLAVE STATUS\G;" | grep 'Waiting for master')
	if [ -z "$SLAVE_OK" ]; then
		echo "  - Error ! Wrong slave IO state."
	else
		echo "  - Slave IO state OK"
	fi
done
