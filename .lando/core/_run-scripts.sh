#!/bin/bash

#
# Helper script to run other scripts and allow overriding them by having same file in .lando/custom folder.
#

set -exu
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/app/vendor/bin

script_name="$1"

# Check if a custom script exists in .lando/custom
custom_script=".lando/custom/$script_name"
core_script=".lando/core/$script_name"

# Check if the custom script exists, and if so, run it.
if [ -f "$custom_script" ]; then
    echo "Running custom script: $custom_script"
    bash "$custom_script"
elif [ -f "$core_script" ]; then
    # If custom script doesn't exist, run the core script.
    echo "Running core script: $core_script"
    bash "$core_script"
else
    echo "Script not found: $script_name"
    exit 1
fi
