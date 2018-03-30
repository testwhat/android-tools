#!/bin/bash
THIS_SCRIPT=$(readlink -f $0)
BASE_PATH=${this_script%/*}

$base_path/SdkManager.sh avd
