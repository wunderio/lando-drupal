#!/bin/bash

#
# Helper script to create db snapshots with mariabackup.
#

set -eo pipefail

# Path to snapshots directory.
db_snapshots_base_dir="/app/.lando/db_snapshots"

# Initialize variables
snapshot_name=""
restore_snapshot_name=""
create_snapshot=false
restore_latest=false

# Check the command-line parameters
if [[ "$1" == "restore" ]]; then
    if [[ -n "$2" && ! "$2" =~ ^-+ ]]; then
        restore_snapshot_name="$2"
    else
        restore_latest=true
    fi
else
    create_snapshot=true

    # check if the '--name' parameter is passed and capture its value
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --name)
                snapshot_name="$2"
                shift
                ;;
            *) ;;
        esac
        shift
    done
fi

#
# Function to generate a snapshot name based on the provided name or timestamp.
#
function generate_complete_snapshot_name() {
  local snapshot_name=$1

  # Retrieve MariaDB version
  local mariadb_version=$(mysql --version | awk '{print $5}')

  # Extract major and minor version from the full version string
  # Example output: 10.3
  local mariadb_major_minor=$(echo "$mariadb_version" | cut -d'.' -f1,2)

  # Generate a timestamp-based snapshot name
  local drupal_short=$(echo "$DB_NAME_DRUPAL" | sed 's/drupal/d/')
  local complete_snapshot_name=$drupal_short"_"$snapshot_name"-mariadb_$mariadb_major_minor"
  echo "$complete_snapshot_name"
}

#
# Function to generate a sanitized snapshot name based on the provided name.
#
function sanitize_snapshot_name() {
  local snapshot_name=$1
  local sanitized_snapshot_name="${snapshot_name//\//__}"
  echo "$sanitized_snapshot_name"
}

#
# Function to create a snapshot with the provided name.
#
function create_snapshot() {
  local snapshot_name=$1
  echo "Creating snapshot..."

  local sanitized_snapshot_name=$(sanitize_snapshot_name "$snapshot_name")
  local db_snapshots_dir="$db_snapshots_base_dir/$sanitized_snapshot_name"
  mkdir -p "$db_snapshots_dir"

  mariabackup --backup --target-dir=$db_snapshots_dir --host=$DB_HOST_DRUPAL --user=root --password=

  # Compress the snapshot directory with lz4 - very fast and effective compression.
  # Eg of compression: 3.8G -> 365M. Total with above mariabackup and lz4: 13 seconds.
  # Compared to tar czf "$db_snapshots_dir.tar.gz" "$db_snapshots_dir"
  # takes 41 seconds to 1m 12 seconds.
  #apt-get install liblz4
  cd "$db_snapshots_base_dir"
  tar cf - "$sanitized_snapshot_name" | lz4 > "$sanitized_snapshot_name.tar.lz4"
  rm -rf "$db_snapshots_dir"

  # Change ownership of the snapshot directory from root to www-data as
  # otherwise it's not readable in host.
  chown www-data:www-data "$db_snapshots_base_dir"
}

function stop_db() {
  # Restart the db master process.
  mysqld_pid=$(pgrep -o mysqld)
  if [ -n "$mysqld_pid" ]; then
    # Send USR2 signal to stop mysqld.
    if kill -USR2 "$mysqld_pid"; then
      echo "Mysqld process (PID $mysqld_pid) stopped."
    else
      echo "Failed to stop mysqld process."
      exit 1
    fi
  else
    echo "Mysqld process not found."
    exit 1
  fi
}

#
# Function to restore a snapshot with the provided name.
#
function restore_snapshot() {
  local snapshot_name=$1
  echo "Restoring snapshot..."

  cd $db_snapshots_base_dir

  local sanitized_snapshot_name=$(sanitize_snapshot_name "$snapshot_name")
  # @todo Remove db_snapshots_dir as it's not used anymore?
  # local db_snapshots_dir="$db_snapshots_base_dir/$sanitized_snapshot_name"

  # Extract the snapshot directory from the compressed file.
  lz4 -d < "$sanitized_snapshot_name.tar.lz4" | tar xf -

  # Ideally we should be stopping the db before restoring the snapshot, but this
  # messes up with the Lando db container. I think stopping is needed only when
  # working with the db on the host. In local we're not doing that.
  # stop_db

  mariabackup --prepare --target-dir=$sanitized_snapshot_name --host=$DB_HOST_DRUPAL --user=root --password=

  # @todo Remove this as it's not used anymore? Do we need backups?
  # mv /bitnami/mariadb/data/ /bitnami/mariadb/data_backup/
  rm -rf /bitnami/mariadb/data/
  cp -rfv $sanitized_snapshot_name /bitnami/mariadb/data/ && rm -rf "$sanitized_snapshot_name"
  chown -R 1001:root  /bitnami/mariadb/data
  find /bitnami/mariadb/data/ -type f -exec chmod 660 {} \;

  # @todo Start db again automatically, for now let's just echo the command.
  #services mysql start
  # For now, echo colored message to restart database
  echo -e "\e[1;33mPlease manually restart Lando to apply changes. Execute this in console:\e[0m"
  echo -e "\e[1;33mlando restart\e[0m"
}

#
# Create a snapshot with the provided name or timestamp (if name is not defined).
#
if [ "$create_snapshot" = true ]; then
    if [ -n "$snapshot_name" ]; then
        complete_snapshot_name=$(generate_complete_snapshot_name "$snapshot_name")
        create_snapshot $complete_snapshot_name
        # Add mariabackup command or any snapshot creation logic here
    else
        timestamp=$(date +"%Y%m%d%H%M%S")
        complete_snapshot_name=$(generate_complete_snapshot_name "$timestamp")
        create_snapshot $complete_snapshot_name
        # Add mariabackup command or any snapshot creation logic here
    fi
fi

#
# Restore a snapshot.
#
if [ -n "$restore_snapshot_name" ]; then
    echo "Restoring snapshot: $restore_snapshot_name"
    #echo $snapshot_name
    complete_snapshot_name=$(generate_complete_snapshot_name "$restore_snapshot_name")
    restore_snapshot $complete_snapshot_name
elif [ "$restore_latest" = true ]; then
    echo "Restoring the latest snapshot"
    # Add restore latest logic here
fi
