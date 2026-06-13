#!/bin/sh

cfg feature:.

java -jar $conf_dev_checkstyle_jar -c $conf_dev_checkstyle_config "$@"
