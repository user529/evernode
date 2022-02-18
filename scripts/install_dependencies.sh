#!/bin/bash
export SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
source $SCRIPT_DIR/env.sh
source $SCRIPT_DIR/functions.sh
#  Redefine log file
test -z $EVS_SCRIPT_LOG && EVS_SCRIPT_LOG="${BASH_SOURCE[0]%.*}.log"
#
check_os
#
function install_yq {
    logging "info" "Install additional tools: yq"
    YQ_GIT="https://github.com/mikefarah/yq/releases/download"
    YQ_VERSION="v4.19.1"
    YQ_URL="${YQ_GIT}/${YQ_VERSION}/yq_${OS_TYPE}_${ARCH}"
    test -x /usr/local/bin/yq || {
        sudo wget "$YQ_URL" -O /usr/local/bin/yq | tee -a "$EVS_SCRIPT_LOG" || exit 1
        sudo chmod a+x /usr/local/bin/yq | tee -a "$EVS_SCRIPT_LOG" || exit 1
    }
}
#
logging "info" "Install dependencies for $DIST_NAME $DIST_VERSION"
case $DIST_ID in 
    debian|ubuntu)
        logging "info" "Root access reqired"
        sudo apt update | tee -a "$EVS_SCRIPT_LOG" || exit 1
        DEPENDENCIES="cmake build-essential pkg-config libssl-dev libtool m4 automake clang git libzstd-dev libgoogle-perftools-dev curl jq vim gawk cron gdb gpg tar python3 python3-pip wget"
        sudo apt install -y $DEPENDENCIES | tee -a "$EVS_SCRIPT_LOG" || exit 1
        sudo apt autoremove | tee -a "$EVS_SCRIPT_LOG" || exit 1
        logging "info" "Install additional tools"
        ;;
    ol)
        dnf check-update  | tee -a "$EVS_SCRIPT_LOG"
        logging "info" "Root access reqired"
        if [[ $(echo "$DIST_VERSION" | tr -d.) -ge $(echo "8.0" | tr -d.) ]]; then
            sudo dnf install -y oracle-epel-release-8el | tee -a "$EVS_SCRIPT_LOG" || exit 1
        fi
        sudo dnf upgrade --security
        DEPENDENCIES="cmake openssl-devel clang gawk zlib zlib-devel libzstd-devel tcl curl jq wget vim libtool logrotate gperftools gperftools-devel"
        sudo dnf install -y $DEPENDENCIES | tee -a "$EVS_SCRIPT_LOG" || exit 1
        sudo dnf group install -y "Development Tools" | tee -a "$EVS_SCRIPT_LOG" || exit 1
        ;;
    *)
        logging "error" "'$OS_TYPE $DIST_NAME $DIST_VERSION' is not supported."
        exit 1
        ;;
esac   
logging "info" "Done. Dependencies are installed successfully."
#
install_yq
#
UID=`id -un`
logging "info" "Enabling lingering for user $UID"
sudo loginctl enable-linger $UID