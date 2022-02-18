#!/bin/bash
#
export SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
source $SCRIPT_DIR/env.sh
source $SCRIPT_DIR/functions.sh
#  Redefine log file
EVS_SCRIPT_LOG="${BASH_SOURCE[0]%.*}.log"
#
./install_dependencies.sh

./nodectl update_repos

./nodectl update_rust

./nodectl build_all

./nodectl copy_executables
#
test -r "$USER_SYSTEMD_DIR/$EVS_SERVICE.service" ||
{ 
    logging "info" "Creating rootless systemd service $EVS_SERVICE"
    test -d "$USER_SYSTEMD_DIR" || 
    {
        mkdir -p "$USER_SYSTEMD_DIR" | tee -a "$EVS_SCRIPT_LOG" 
        test $? -gt 0 && exit 1
    }
    test -z "$EVS_SERVICE" && 
    {
        logging "error" "Environment variable EVS_SERVICE is not set. Please set it in env_default.sh or env_local.sh"; 
        exit 1 
    }
    #
    cat << EOD > "$USER_SYSTEMD_DIR/$EVS_SERVICE.service"
[Unit]
Description=Everscale validator Node
Wants=network.target
After=network-online.target
StartLimitIntervalSec=0

[Service]
Environment=
Type=simple
Restart=on-failure
RestartSec=1
LimitNOFILE=2048000
ExecStart=$CALL_EN
ExecStop=/bin/kill -HUP

[Install]
WantedBy=multi-user.target default.target
EOD
    #
    test -r "$USER_SYSTEMD_DIR/$EVS_SERVICE.service" || 
    {
        logging "error" "Systemd service file is not found: $USER_SYSTEMD_DIR/$EVS_SERVICE.service"; 
        exit 1 
    }
    logging "info" "Node $EVS_SERVICE has been setup successfully."
}
#
./initial_configuration.sh
#
./nodectl service_stop

./nodectl service_start