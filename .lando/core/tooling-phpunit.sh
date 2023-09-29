#!/bin/sh

#
# Helper script to run PHPUnit.
#

set -exu
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/app/vendor/bin

php /app/vendor/bin/phpunit -c /app/phpunit.xml --testdox
