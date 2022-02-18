#!/bin/bash

#  Redefine log file
EVS_SCRIPT_LOG="${BASH_SOURCE[0]%.*}.log"
#
./nodectl update_repos

./nodectl update_rust

./nodectl build_all