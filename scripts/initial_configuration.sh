#!/bin/bash
#
#######################################################################################
#
#  This script is supposed to be run only once, at the first installation of the node
#
#######################################################################################
#
export SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
source $SCRIPT_DIR/env.sh
source $SCRIPT_DIR/functions.sh
#
#  Redefine log file
test -z $EVS_SCRIPT_LOG && EVS_SCRIPT_LOG="${BASH_SOURCE[0]%.*}.log"
#
function check_prepare_dir {
    DIR_NAME="$1"
    test -d "$DIR_NAME" || mkdir -p "$DIR_NAME" ||
    {
        logging "error" "Unable to create or access the directory: $DIR_NAME"
        exit 1
    }
    chmod 700 "$DIR_NAME" || exit 1
}
#
check_os
#
logging "info" "Make sure that only the owner has access to the evernode directory"
chmod -R go-rwx $(dirname $SCRIPT_DIR) || exit 1
#
logging "info" "Prepare the node root directory"
check_prepare_dir "$EVS_ROOT"
#
logging "info" "Prepare the log directory"
check_prepare_dir "$EVS_LOGS"
#
logging "info" "Prepare the node temp directory"
check_prepare_dir "$EVS_TEMP"
#
logging "info" "Preparing working DB directory"
check_prepare_dir "$EVS_DB" 
#
logging "info" "Checking if the working DB directory is empty"
ls -1qA "$EVS_DB" | grep -q . && IS_EMPTY="N" || IS_EMPTY="Y"
test "$IS_EMPTY" == "N" && 
{
    logging "error" "DB directory is not empty: $EVS_DB. Canot setup a new instance to the same directory."
    exit 1
}
#
logging "info" "Preparing keys directory"
check_prepare_dir "$EVS_KEYS"
logging "info" "Checking if the keys directory is empty"
ls -1qA "$EVS_KEYS" | grep -q . && IS_EMPTY="N" || IS_EMPTY="Y"
test "$IS_EMPTY" == "N" && 
{
    logging "warning" "Keys directory is not empty: $EVS_KEYS, processing could erase data. Do you want to continue (y/N)?"
    declare -l ANSWER
    IFS= read ANSWER
    if [ "$ANSWER" == "N"]; then
        exit 1
    fi
    logging "warning" "The user decided to continue with the existing keys!"
}
#
logging "info" "Preparing bin directory"
check_prepare_dir "$EVS_BIN"
#
logging "info" "Preparing directory for storing config data"
check_prepare_dir "$EVS_CONFIG"
#
logging "info" "Preparing directory for storing election data"
check_prepare_dir "$EVS_ELECTION"
#
logging "info" "Start composing config files" 
# Configs source files
DEFAULT_CONFIG="$EVS_NODE/configs/default_config.json"
DEFAULT_LOG_CFG="$EVS_NODE/common/config/log_cfg.yml"
CONSOLE_TEMPLATE="$EVS_NETTYPE/docker-compose/ton-node/configs/console_template.json"
#
logging "info" "Copying ton-global.config.json"
cp -f "$EVS_NETTYPE/configs/ton-global.config.json" "$EVS_CONFIG/"
#
logging "info" "Generating log_cfg"
cp -f "$DEFAULT_LOG_CFG" "$EVS_TEMP/log_cfg.tmp"
yq -e eval " \
.appenders.logfile.path = \"$EVS_NODE_LOG\", \
.appenders.rolling_logfile.path = \"$EVS_NODE_LOG\", \
.appenders.rolling_logfile.policy.roller.pattern = \"$EVS_LOGS/rnode_{}.log\"" -i "$EVS_TEMP/log_cfg.tmp"
test $? -gt 0 &&
{
    logging "error" "Unable to generate log_cfg file: $EVS_TEMP/log_cfg.tmp"
    exit 1
}
mv -f "$EVS_TEMP/log_cfg.tmp"  "$EVS_CONFIG/log_cfg.yml"
#
logging "info" "Generating default_config"
rm -f "$EVS_TEMP/default_config.tmp" 2>/dev/null
jq -e " \
.log_config_name |= \"$EVS_CONFIG/log_cfg.yml\" | \
.ton_global_config_name |= \"$EVS_CONFIG/ton-global.config.json\" | \
.internal_db_path |= \"$EVS_DB\" | \
.ip_address |= \"${EVS_IP_ADDR}:${EVS_ADNL_PORT}\" | \
.control_server_port |= $EVS_EXT_PORT" "$DEFAULT_CONFIG" > "$EVS_TEMP/default_config.tmp"
test $? -gt 0 && 
{
    logging "error" "Unable to generate node config file: $EVS_TEMP/default_config.tmp"
    exit 1
}
mv -f "$EVS_TEMP/default_config.tmp"  "$EVS_CONFIG/default_config.json"
#
logging "info" "Generating console client keys"
$EVS_BIN/keygen > "$EVS_CONFIG/${HOSTNAME}_console_client_keys.json"
jq -c '.public' "$EVS_CONFIG/${HOSTNAME}_console_client_keys.json" > "$EVS_CONFIG/console_client_public.json"
#
logging "info" "Generating config.json"
$CALL_EN --ckey "$(cat $EVS_CONFIG/console_client_public.json)" | tee -a "$EVS_SCRIPT_LOG" &
#
for i in {1..10}
do
    sleep 1
    test -f "$EVS_CONFIG/config.json" && {
        logging "info" "config.json generated"
        break
    }
done
#
pkill evernode &>/dev/null
#
test -f "$EVS_CONFIG/config.json" ||
{
    logging "error" "Unable to generate node config file: $EVS_CONFIG/config.json. Check node logs in $EVS_LOGS"
    exit 1
}
#
test -f "$EVS_CONFIG/console_config.json" ||
{
    logging "error" "Unable to generate node config file: $EVS_CONFIG/console_config.json. Check node logs in $EVS_LOGS"
    exit 1
}
#
jq -e ".client_key = $(jq .private "$EVS_CONFIG/${HOSTNAME}_console_client_keys.json")" "$EVS_CONFIG/console_config.json" > "$EVS_TEMP/console_config.json.tmp"
test $? -gt 0 && 
{
    logging "error" "Unable to create console config over private key"
    exit 1
}
jq -e ".config = $(cat $EVS_TEMP/console_config.json.tmp)" "$CONSOLE_TEMPLATE" > "$EVS_CONFIG/console.json"
test $? -gt 0 && 
{
    logging "error" "Unable to create console.json"
    exit 1
}
#
logging "info" "Clean temporary folder"
rm -f "$EVS_TEMP/*"
#
logging "info" "Done. The evernode has been successfully setup."
