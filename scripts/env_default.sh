##########################################################
#
#  Please do not change THIS file!
#  Copy it as env_local.sh in the same directory instead 
#  and then make appropriate modifications in the env_local.sh
#
##########################################################
#
#  Network
#export NETWORK_TYPE="main.ton.dev"
#export NETWORK_TYPE="rustnet.ton.dev"
export NETWORK_TYPE="net.ton.dev"
export EVS_IP_ADDR="0.0.0.0"
export EVS_ADNL_PORT="30303"
export EVS_EXT_PORT="3031"
#
##########################################################
#
#  Service name
export EVS_SERVICE='evernode'
#
##########################################################
#
#  General dirs
#  Root dir. 
#  Can be located on the usual HDD or SSD
export EVS_ROOT=/opt/everscale
#  Path for storing a temporary data
export EVS_TEMP=/tmp/everscale
#  Work dir (database)
#  It is recommended to use a separate NVME drive for the database
export EVS_DB=/u01/$EVS_SERVICE
#
##########################################################
#
#  Msig contract alias
#
export MSIG_ALIAS='msig'
#
##########################################################
#
#  Depool contract alias
#
export DEPOOL_ALIAS='depool'
#  If depool's balance lower than DEPOOL_THR 
#  then fts will try to replenish depool contract from msig with DEPOOL_REPL amount 
export DEPOOL_THR=25
export DEPOOL_REPL=10
# If sending stake has failed, how many times should the fts repeat sending?
export DEPOOL_ATTEMPTS=1
#
##########################################################
#
#  Tick contract alias
#
export TICK_ALIAS='tick'
#  If tick's balance lower than TICK_THR
#  then fts will try to replenish it from msig with TICK_REPL amount
export TICK_THR=3
export TICK_REPL=5
# If the tick has failed, how many times should the fts repeat sending the tick to the depool?
export TICK_ATTEMPTS=1
#
##########################################################
#
#  Custodian contract
#  Kindly note that due to security reasons 
#  it is not recommended storing custodian keys 
#  on the same node next to msig and depool.
#  Please use a separate VPS as the custodian.
#  In case, despite the above, you do want 
#  to have a custodian keys on the same node 
#  then override CSTDN_ENABLED and set it 'true'
export CSTDN_ENABLED='false'
#  Will be used if only CSTDN_ENABLED='true'
export CSTDN_ALIAS='custodian'
#
##########################################################
#
#  Telegram Bot Config
#  This is a stub-file!
#  Please save the real Telegram Bot config in the local file (e.g. $HOME/TgBotConfig.json) and redefine the file path in env_local.sh
export TG_CONFIG=${EVS_KEYS}/StubConfig.json
#
##########################################################