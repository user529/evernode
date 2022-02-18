
export SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`

#
# Environment customization
CUSTOM_ENV_FILE="env_local.sh"
if [ -r "$SCRIPT_DIR/$CUSTOM_ENV_FILE" ]; then
    source "$SCRIPT_DIR/$CUSTOM_ENV_FILE"
else 
    source "$SCRIPT_DIR/env_default.sh"
fi
#
##########################################################
#
#  Contract aliases must be specified in env_default.sh or env_local.sh!
#  MSIG_ALIAS, DEPOOL_ALIAS, TICK_ALIAS, CSTDN_ALIAS
#
export MSIG_ABI=$EVS_CONTRACTS/solidity/safemultisig/SafeMultisigWallet.abi.json
export MSIG_ADDR=`test -r ${EVS_KEYS}/${MSIG_ALIAS}.addr && cat ${EVS_KEYS}/${MSIG_ALIAS}.addr`
export MSIG_KEY=${EVS_KEYS}/${MSIG_ALIAS}.key.json
#  
export DEPOOL_ABI=$EVS_CONTRACTS/solidity/depool/DePool.abi.json
export DEPOOL_ADDR=`test -r ${EVS_KEYS}/${DEPOOL_ALIAS}.addr && cat ${EVS_KEYS}/${DEPOOL_ALIAS}.addr`
export DEPOOL_KEY=${EVS_KEYS}/${DEPOOL_ALIAS}.key.json
#
export TICK_ABI=$EVS_CONTRACTS/solidity/safemultisig/SafeMultisigWallet.abi.json
export TICK_ADDR=`test -r ${EVS_KEYS}/${TICK_ALIAS}.addr && cat ${EVS_KEYS}/${TICK_ALIAS}.addr`
export TICK_KEY=${EVS_KEYS}/${TICK_ALIAS}.key.json
#
export CSTDN_ABI=$EVS_CONTRACTS/solidity/safemultisig/SafeMultisigWallet.abi.json
export CSTDN_ADDR=`test -r ${EVS_KEYS}/${CSTDN_ALIAS}.addr && cat ${EVS_KEYS}/${CSTDN_ALIAS}.addr`
export CSTDN_KEY=${EVS_KEYS}/${CSTDN_ALIAS}.key.json
#
##########################################################
#
#  Elector contract
#
export ELECTOR_ADDR=`test -r ${EVS_KEYS}/elector.addr && cat ${EVS_KEYS}/elector.addr`
#export ELECTOR_ABI=$EVS_CONTRACTS/Elector.abi.json # reserved for the future use, when the new elector will be introduced
#
# General dirs must be specified in env_default.sh or env_local.sh!
# EVS_ROOT, EVS_SERVICE
#
#  Path to node dir sources
export EVS_NODE="$EVS_ROOT/sources/node"
#  Path to node tools sources
export EVS_TOOLS="$EVS_ROOT/sources/node_tools"
#  Path to everos-cli sources
export EVS_CLI="$EVS_ROOT/sources/everos-cli"
#  Path to contracts and ABI
export EVS_CONTRACTS="$EVS_ROOT/contracts"
#  Path to network type configs
export EVS_NETTYPE="$EVS_ROOT/$NETWORK_TYPE"
#  Path to node executable tools: console, rnode, everos-cli, etc
export EVS_BIN="$EVS_ROOT/bin"
#  Path to keys and addresses
export EVS_KEYS="$EVS_ROOT/keys"
#  Path to configs files for node execuables: console.json, everos-cli.conf.json
export EVS_CONFIG="$EVS_ROOT/config"
#  Path for storing the current election data
export EVS_ELECTION="$EVS_ROOT/election"
#  Path for validator python scripts
export EVS_VSCRIPTS="$EVS_ROOT/vscripts"
#  Node logs dir
export EVS_LOGS="$EVS_ROOT/logs"
export EVS_SCRIPT_LOG="$EVS_LOGS/scripts.log"
export EVS_NODE_LOG="$EVS_LOGS/$EVS_SERVICE.log"
#
##########################################################
#
#  Git & commits
#
export EVS_NODE_REPO="https://github.com/tonlabs/ton-labs-node.git"
export EVS_NODE_COMMIT="master"
#export EVS_NODE_FEATURES="metrics,compression"
#
export EVS_TOOLS_REPO="https://github.com/tonlabs/ton-labs-node-tools.git"
export EVS_TOOLS_COMMIT="master"
#
export EVS_CLI_REPO="https://github.com/tonlabs/tonos-cli.git"
export EVS_CLI_COMMIT="master"
#
export EVS_CONTRACTS_REPO="https://github.com/tonlabs/ton-labs-contracts.git"
export EVS_CONTRACTS_COMMIT="master"
#
export EVS_NETTYPE_REPO="https://github.com/tonlabs/${NETWORK_TYPE}.git"
export EVS_NETTYPE_COMMIT="master"
#
##########################################################
#
#  Executables
#
export CALL_EC="$EVS_BIN/everos-cli --json --config $EVS_CONFIG/everos-cli.conf.json"
export CALL_RC="$EVS_BIN/console --json --config $EVS_CONFIG/console.json"
export CALL_EN="$EVS_BIN/evernode --configs $EVS_CONFIG"
#
##########################################################
#
#  Required tools versions
#
export REQUIRED_EC="0.24.11"
#
##########################################################
#
export USER_SYSTEMD_DIR=~/.config/systemd/user
test -z "$EVS_IP_ADDR" && export EVS_IP_ADDR=`curl -4 http://l2.io/ip` #`curl -4 https://api.ipify.org/`
test -z "$EVS_ADNL_PORT" && export EVS_ADNL_PORT="30303"
test -z "$EVS_EXT_PORT" && export EVS_EXT_PORT="3031"
test -z "$EVS_INT_IP" && export EVS_INT_IP="127.0.0.1"
test -z "$EVS_INT_PORT" && export EVS_INT_PORT="3030"
#
##########################################################