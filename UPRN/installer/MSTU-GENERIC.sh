NAME="MSTU"
USER="root"
set -e
. /lib/lsb/init-functions

start() {
  printf "Starting PS > '$NAME'... "
  export USER=$USER
  monkey=$(cat "$API_DIR/certs/monkey3.txt")
  printf $monkey
  #export ydb_dist=/usr/local/lib/yottadb/r126
  export ydb_dist="$MUMPS_INSTALL_DIR"
  export ydb_gbldir="$INSTALL_DIR"/.yottadb/"$ydb_rel"/g/yottadb.gld
  export ydb_dir="$INSTALL_DIR"/.yottadb
  export ydb_rel="$ydb_rel"
  export gtmtls_passwd_dev=$monkey
  export gtmcrypt_config="$API_DIR/gtmcrypt_config.libconfig"
  export ydb_routines="$INSTALL_DIR"/.yottadb/"$ydb_rel"/r/
  cd "$INSTALL_DIR"/.yottadb/"$ydb_rel"/r/
  "$MUMPS_INSTALL_DIR"/ydb -run ^START
  printf "done\n"
}

stop() {
  printf "Stopping PS > '$NAME'... "
  export USER=$USER
  export ydb_dist="$MUMPS_INSTALL_DIR"
  export ydb_gbldir="$INSTALL_DIR"/.yottadb/"$ydb_rel"/g/yottadb.gld
  export ydb_dir="$INSTALL_DIR"/.yottadb
  export ydb_rel="$ydb_rel"
  export ydb_routines="$INSTALL_DIR"/.yottadb/"$ydb_rel"/r/
  cd "$INSTALL_DIR"/.yottadb/"$ydb_rel"/r/
  "$MUMPS_INSTALL_DIR"/ydb -run STOP^START
  printf "done\n"
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $NAME {start|stop|restart}" >&2
    exit 1
    ;;
esac

exit 0