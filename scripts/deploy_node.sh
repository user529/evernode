#!/bin/bash
#
#  Redefine log file
EVS_SCRIPT_LOG="${BASH_SOURCE[0]%.*}.log"
#
./nodectl copy_executables

./nodectl service_stop

./nodectl service_start
