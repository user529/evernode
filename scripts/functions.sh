
# install_dependencies
# refresh_repo "REPO_URL" ["REPO_COMMIT" "DEST_DIR"]
# update_repos - clone or update all necessary git repos
# install rust - install recommended rust version
# build_node - run build node from sources
# build_tools - run build node tools from sources
# build_cli - run build everos-cli from sources
# build_all - node, tools and everos-cli
# depoly node
# copy executables
# create systemd service
# restart systemd service

## todo:
### create keys, contracts, etc# 
#
#
CMD_LIST="check_os|update_repos|update_rust|build_node|build_tools|build_cli|build_all|copy_executables|service_start|service_stop"

function logging {
    test -z "$EVS_SCRIPT_LOG" && EVS_SCRIPT_LOG=$EVS_LOGS/scripts.log
    test -w "$EVS_SCRIPT_LOG" || touch "$EVS_SCRIPT_LOG" || exit 1
    local DATETIME=`date "+%Y-%m-%d %H:%M:%S"`
    local -u TYPE=${1}

    if [ -z "$TYPE" ]; then
        local MESSAGE=${@}
        echo "$DATETIME WARNING Message type is not set." | tee -a "$EVS_SCRIPT_LOG"
        local TYPE="INFO"
    else
        local MESSAGE=${@:2}
    fi

    echo "$DATETIME $TYPE $MESSAGE" | tee -a "$EVS_SCRIPT_LOG"
}

function check_os {
    logging "info" "Checking the OS type and version of the distribution."
    OS_TYPE=`uname -s`
    ARCH=`arch`
    if [[ "$OS_TYPE" == "Linux" ]]; then
        DIST_ID=`cat /etc/*release | grep ^ID= | awk -F= '{print $2}' | tr -d '"'`
        DIST_NAME=`cat /etc/*release | grep ^NAME= | awk -F= '{print $2}' | tr -d '"'`
        DIST_VERSION=`cat /etc/*release | grep ^VERSION= | awk -F= '{print $2}' | tr -d '"'`
    else
        logging "error" "$OS_TYPE is not supported."
        exit 1
    fi

    case $ARCH in
        i386|i686) ARCH="386" ;;
        x86_64)    ARCH="amd64" ;;
        *)  logging "error" "$OS_TYPE is not supported."
            exit 1
            ;;
    esac

    case $DIST_ID in 
        debian|ubuntu|ol)
            logging "info" "$DIST_NAME $DIST_VERSION ($OS_TYPE $DIST_ID $ARCH)"
            ;;
        *)
            logging "error" "$DIST_NAME $DIST_VERSION ($OS_TYPE $DIST_ID $ARCH) is not supported."
            exit 1
            ;;
    esac
}

function refresh_repo {
    logging "info" "Updating repo $1"
    if [ -z "$1" ]; then
        logging "error" "Source repository is not given."
        exit 1
    fi
    declare REPO_URL=$1

    if [ -z "$2" ]; then
        logging "error" "Repo commit is not given."
        exit 1
    fi
    declare REPO_COMMIT=$2

    if [ -z "$3" ]; then
        logging "error" "Destination directory is not given."
        exit 1
    fi
    declare DEST_DIR=$3

    if [ -d "$DEST_DIR" ]; then
        git -C "$DEST_DIR" fetch --all --prune | tee -a "$EVS_SCRIPT_LOG" || exit 1
        git -C "$DEST_DIR" checkout "$REPO_COMMIT" | tee -a "$EVS_SCRIPT_LOG" || exit 1
        git -C "$DEST_DIR" reset --hard "origin/$REPO_COMMIT" | tee -a "$EVS_SCRIPT_LOG" || exit 1
    else
        git clone "$REPO_URL" "$DEST_DIR" | tee -a "$EVS_SCRIPT_LOG" || exit 1
        git -C "$DEST_DIR" checkout "$REPO_COMMIT" | tee -a "$EVS_SCRIPT_LOG" || exit 1
    fi
    git -C "$DEST_DIR" submodule init | tee -a "$EVS_SCRIPT_LOG" || exit 1
    git -C "$DEST_DIR" submodule update --recursive | tee -a "$EVS_SCRIPT_LOG" || exit 1
}

function update_repos {
    logging "info" "Start updating all repositories"
    # Get/update evernode repo
    refresh_repo "$EVS_NODE_REPO" "$EVS_NODE_COMMIT" "$EVS_NODE"

    # Get/update evernode tools repo
    refresh_repo "$EVS_TOOLS_REPO" "$EVS_TOOLS_COMMIT" "$EVS_TOOLS"

    # Get/update evernode everos-cli repo
    refresh_repo "$EVS_CLI_REPO" "$EVS_CLI_COMMIT" "$EVS_CLI"

    # Get/update everscale contracts repo
    refresh_repo "$EVS_CONTRACTS_REPO" "$EVS_CONTRACTS_COMMIT" "$EVS_CONTRACTS"

    # Get/update everscale contracts repo
    refresh_repo "$EVS_NETTYPE_REPO" "$EVS_NETTYPE_COMMIT" "$EVS_NETTYPE"
}

function update_rust {
    logging "info" "Updating RUST"
    test -z "$RUST_VERSION" && RUST_VERSION=`cat "$EVS_NODE/recomended_rust"`
    logging "info" "version $RUST_VERSION"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain $RUST_VERSION -y
}

function build_node {
    logging "info" "Start building node"
    cd "$EVS_NODE"
    logging "info" "    DIR: $(pwd)"
    logging "info" "    REPO: $EVS_NODE_REPO"
    logging "info" "    COMMIT: $EVS_NODE_COMMIT"
    logging "info" "making cargo update"
    cargo update 2>&1 | tee -a "$EVS_SCRIPT_LOG" || exit 1
    logging "info" "running cargo build"
    if [ -n "$EVS_NODE_FEATURES" ]; then 
         EVS_NODE_FEATURES = "--features \"$EVS_NODE_FEATURES\""
    fi
    RUSTFLAGS="-C target-cpu=native" cargo build --release $EVS_NODE_FEATURES 2>&1 | tee -a "$EVS_SCRIPT_LOG" || exit 1
    logging "info" "Node has been builded"
}

function build_tools {
    logging "info" "Start building node tools"
    cd "$EVS_TOOLS"
    logging "info" "    DIR: $(pwd)" 
    logging "info" "    REPO: $EVS_TOOLS_REPO"
    logging "info" "    COMMIT: $EVS_TOOLS_COMMIT"
    logging "info" "making cargo update"
    cargo update 2>&1 | tee -a "$EVS_SCRIPT_LOG" || exit 1
    logging "info" "running cargo build"
    cargo build --release 2>&1 | tee -a "$EVS_SCRIPT_LOG" || exit 1
    logging "info" "Node tools has been builded"
}

function build_cli {
    logging "info" "Start building everos-cli"
    cd "$EVS_CLI"
    logging "info" "   DIR: $(pwd)"
    logging "info" "   REPO: $EVS_CLI_REPO"
    logging "info" "   COMMIT: $EVS_CLI_COMMIT"
    logging "info" "making cargo update"
    cargo update 2>&1 | tee -a "$EVS_SCRIPT_LOG" || exit 1
    logging "info" "running cargo build"
    cargo build --release 2>&1 | tee -a "$EVS_SCRIPT_LOG" || exit 1
    logging "info" "everos-cli has been builded"
}

function build_all {
    build_node
    build_tools
    build_cli
    logging "info" "Done: node, tools, everos-cli has been builded"
}

function copy_executables {
    logging "info" "Coping executables"
    test -d "$EVS_BIN" || mkdir -p "$EVS_BIN" || exit 1
    cp -f "$EVS_NODE/target/release/ton_node" "$EVS_BIN/evernode"  | tee -a "$EVS_SCRIPT_LOG" || exit 1
    find "$EVS_TOOLS/target/release/" -maxdepth 1 -type f -executable -exec cp -f {} "$EVS_BIN"/ \;
    cp -f "$EVS_CLI/target/release/tonos-cli" "$EVS_BIN/everos_cli"  | tee -a "$EVS_SCRIPT_LOG" || exit 1
    logging "info" "Done. The executables files are in place"
}

function dbus_workaround {
  if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    logging "info" "Applying workaround for dbus"
    test -z "$UID" && declare UID=$(id -u)
    test -d /run/user/$UID || 
    {
        logging "error" "The user session is not started. Please login properly (use 'login' or 'machinectl login' instead of 'su' or 'sudo')"
        exit 1
    }
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UID/bus
    if [[ $(ps -fu $UID | grep -v grep | grep -c dbus-daemon) == 0 ]]; then
      logging "info" "Exporting DBUS_SESSION_BUS_ADDRESS and forking dbus-daemon"
      dbus-launch --auto-syntax dbus-daemon --fork --session --print-address 1 --address=$DBUS_SESSION_BUS_ADDRESS | tee -a "$EVS_SCRIPT_LOG"
      if [ -z "$XDG_RUNTIME_DIR" ]; then
        logging "info" "Exporting XDG_RUNTIME_DIR"
        export XDG_RUNTIME_DIR=$(echo $DBUS_SESSION_BUS_ADDRESS | cut -d, -f1)
        logging "warning" "Kindly note that it's required to enable the current user lingering. In order to do that please run the following command:"
        logging "warning" "  sudo loginctl enable-linger $(whoami)"
        logging "warning" "Otherwise the service cannot be run automatically after reboot"
      fi
    fi
  fi
}

function service_start {
    logging "info"  "Starting rootless systemd service $EVS_SERVICE"
    systemctl --user enable $EVS_SERVICE | tee -a "$EVS_SCRIPT_LOG"
    systemctl --user daemon-reload | tee -a "$EVS_SCRIPT_LOG"
    systemctl --user start $EVS_SERVICE | tee -a "$EVS_SCRIPT_LOG"
}

function service_stop {
    logging "info"  "Stopping rootless systemd service $EVS_SERVICE"
    systemctl --user stop $EVS_SERVICE | tee -a "$EVS_SCRIPT_LOG"
    systemctl --user disable $EVS_SERVICE | tee -a "$EVS_SCRIPT_LOG"
    systemctl --user daemon-reload | tee -a "$EVS_SCRIPT_LOG"
}