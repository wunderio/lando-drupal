#!/bin/sh

#
# Helper script to run appserver build commands.
#

set -exu
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/app/vendor/bin

composer install
