#!/bin/bash

source /etc/init.d/functions.sh

function display_usage() {
	einfo "Gentoo Netbeans 6.0 Configuration Utility"
	einfo
	einfo "Usage ${0} <action>"
	einfo "Actions:"
	einfo "  ant - Configures Netbeans 6.0 ant classpath. Useful if you want to use ant-1.7 with Netbeans."
	einfo "        Default Netbeans configuration doesn't work with Gentoo ant-1.7 because Gentoo ant-1.7"
	einfo "        is split into several packages in separate directories whereas default Netbeans"
	einfo "        configuration expects all these packages being in single directory. You must define"
	einfo "        paths to these packages in Netbeans ant configuration so ant can find them. This action"
	einfo "        configures Netbeans ant classpath for you so ant knows where these packages are. You"
	einfo "        can modify the classpath in Tools -> Options -> Miscellaneous -> Ant -> Manage Classpath."
	einfo "  lm  - Copies settings of Library Manager from one version of Netbeans to another so you do not"
	einfo "        have to define/update it manually. It is useful if you are upgrading from 5.5 to 6.0 or"
	einfo "        you use both 5.5 and 6.0 and want to copy the settings from one version to the other."
	einfo "        Netbeans 5.5 and 6.0 are supported."
}

function config_ant() {
	einfo "Gentoo Netbeans 6.0 Configuration Utility - Ant Configuration"
	einfo
	einfo "Provide path to your Netbeans home dir."
	einfo "Default is [${HOME}/.netbeans/dev]:"
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
	echo "extraClasspath=$(java-config -dp ant-tasks | sed -e 's/:/\\:/g')" >> ${FILE} \
		|| die "Ant classpath update failed"

	einfo
	einfo "Ant configuration file has been updated"
}

function config_lm() {
	einfo "Gentoo Netbeans 6.0 Configuration Utility - Library Manager Configuration"
	einfo
	einfo "Provide path to Netbeans user dir you want to copy the configuration FROM."
	einfo "Default is [${HOME}/.netbeans/5.5]:"
	read SOURCE
	if [ -z "${SOURCE}" ]; then
		SOURCE="${HOME}/.netbeans/5.5"
	fi
	if [ ! -d "${SOURCE}" ]; then
		eerror "Directory ${SOURCE} does not exist."
		return 1
	fi
	einfo "Provide path to Netbeans user dir you want to copy the configuration TO."
	einfo "Default is [${HOME}/.netbeans/dev]:"
	read TARGET
	if [ -z "${TARGET}" ]; then
		TARGET="${HOME}/.netbeans/dev"
	fi
	if [ ! -d "${TARGET}" ]; then
		eerror "Directory ${TARGET} does not exist."
		return 1
	fi
	einfo "Copying Library Manager configuration"
	einfo "from: ${SOURCE}"
	einfo "to  : ${TARGET}"
	cp -R ${SOURCE}/config/org-netbeans-api-project-libraries/* ${TARGET}/config/org-netbeans-api-project-libraries/ \
		|| die "Cannot copy Library Manager configuration"

	einfo
	einfo "Library Manager configuration files has been updated"
}


case ${1} in
	ant)
	config_ant
	;;

	lm)
	config_lm
	;;

	*)
	display_usage
	;;
esac
