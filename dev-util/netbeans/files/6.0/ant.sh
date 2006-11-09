#!/bin/bash

source /etc/init.d/functions.sh

einfo "Provide path to your Netbeans home dir. Default is ${HOME}/.netbeans/dev:"
read USERDIR
if [ -z "${USERDIR}" ]; then
	USERDIR="${HOME}/.netbeans/dev"
fi

FILE="${USERDIR}/config/Preferences/org/apache/tools/ant/module.properties"
if [ ! -f ${FILE} ]; then
	eerror "Cannot find ant configuration file ${FILE}"
	return 1
fi

einfo "Updating file ${FILE}"
sed -i -e "s/extraClasspath=.*//" ${FILE}
echo "extraClasspath=$(java-config -dp ant-tasks | sed -e 's/:/\\:/g')" >> ${FILE}

einfo "Ant configuration file has been updated"

