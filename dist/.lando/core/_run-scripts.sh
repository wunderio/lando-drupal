#!/bin/sh

#
# Helper script to run other scripts and allow overriding them by having the same file in .lando/custom folder.
#

set -exu
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/app/vendor/bin

script_name="$1"
# Remove the first argument (the script name) to get the remaining arguments
shift 1

custom_script="/app/.lando/custom/$script_name"
core_script="/app/.lando/core/$script_name"

# Check if the custom script exists and is executable
if [ -x "$custom_script" ]; then
    echo "Running custom script: $custom_script"
    # Run the script and pass all remaining arguments.
    "$custom_script" "$@"
elif [ -x "$core_script" ]; then
    # If the custom script doesn't exist, run the core script.
    echo "Running core script: $core_script"
    # Run the script and pass all remaining arguments.
    "$core_script" "$@"
else
    echo "Script not found or not executable: $script_name"
    exit 1
fi
