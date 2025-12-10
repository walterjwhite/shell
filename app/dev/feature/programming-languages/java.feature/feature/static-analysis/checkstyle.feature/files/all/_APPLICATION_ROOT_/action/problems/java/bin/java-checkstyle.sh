#!/bin/sh

java -jar ${_CONF_APPLICATION_LIBRARY_PATH}/checkstyle/checkstyle.jar -c ${_CONF_APPLICATION_LIBRARY_PATH}/checkstyle/checks/${_CONF_DEV_CHECKSTYLE_VERSION_STYLE}_checks.xml "$@"
