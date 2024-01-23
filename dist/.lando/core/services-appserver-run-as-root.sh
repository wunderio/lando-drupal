#!/bin/sh

#
# Helper script to run appserver run_as_root commands.
#

set -exu
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/app/vendor/bin

ln -snf /usr/share/zoneinfo/Europe/Helsinki /etc/localtime
echo "Europe/Helsinki" > /etc/timezone
