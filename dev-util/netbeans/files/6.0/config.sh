#!/bin/bash

source /etc/init.d/functions.sh

function display_usage() {
	einfo "Gentoo Netbeans 6.0 Configuration Utility"
	einfo
	einfo "Usage ${0} <action>"
	einfo "Actions:"
	einfo "  ant      - Configures Netbeans 6.0 ant classpath. Useful if you want to use ant-1.7 with Netbeans."
	einfo "             Default Netbeans configuration doesn't work with Gentoo ant-1.7 because Gentoo ant-1.7"
	einfo "             is split into several packages in separate directories whereas default Netbeans"
	einfo "             configuration expects all these packages being in single directory. You must define"
	einfo "             paths to these packages in Netbeans ant configuration so ant can find them. This action"
	einfo "             configures Netbeans ant classpath for you so ant knows where these packages are. You"
	einfo "             can modify the classpath in Tools -> Options -> Miscellaneous -> Ant -> Manage Classpath."
	einfo "  lm       - Copies settings of Library Manager from one version of Netbeans to another so you do not"
	einfo "             have to define/update it manually. It is useful if you are upgrading from 5.5 to 6.0 or"
	einfo "             you use both 5.5 and 6.0 and want to copy the settings from one version to the other."
	einfo "             Netbeans 5.5 and 6.0 are supported."
	einfo "  tomcat55 - Adds Tomcat 5.5 configuration to Netbeans Server Manager. Tomcat 5.5 must be installed"
	einfo "             before it can be used from Netbeans."
	einfo "  jboss4   - Adds JBoss 4.x configuration to Netbeans Server Manager. JBoss 4.x must be installed"
	einfo "             before it can be used from Netbeans."
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

	einfo "Updating file ${FILE}"
	FILE="${USERDIR}/config/Preferences/org/apache/tools/ant/module.properties"
	if [ ! -f ${FILE} ]; then
		mkdir -p `dirname ${FILE}`
		echo "extraClasspath=$(java-config -dp ant-tasks | sed -e 's/:/\\:/g')" >> ${FILE} \
			|| die "Ant classpath update failed"
	else
		sed -i -e "s/extraClasspath=.*//" ${FILE}
		echo "extraClasspath=$(java-config -dp ant-tasks | sed -e 's/:/\\:/g')" >> ${FILE} \
			|| die "Ant classpath update failed"
	fi

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

config_tomcat55() {
	SERVER_NAME="Tomcat 5.5"
	INSTANCE_CONFIG="        <attr name=\"admin_port\" stringvalue=\"8005\"/>
        <attr name=\"debug_type\" stringvalue=\"SEL_debuggingType_socket\"/>
        <attr name=\"displayName\" stringvalue=\"Tomcat 5.5\"/>
        <attr name=\"httpportnumber\" stringvalue=\"8080\"/>
        <attr name=\"instance_id\" stringvalue=\"tomcat55\"/>
        <attr name=\"monitor_enabled\" stringvalue=\"false\"/>
        <attr name=\"password\" stringvalue=\"password\"/>
        <attr name=\"runningCheckTimeout\" stringvalue=\"2000\"/>
        <attr name=\"timestamp\" stringvalue=\"1161241641000\"/>
        <attr name=\"url\" stringvalue=\"tomcat55:home=/usr/share/tomcat-5.5:base=/var/lib/tomcat-5.5\"/>
        <attr name=\"username\" stringvalue=\"ide\"/>"
	PROPERTIES_FILE="tomcat55.properties"
	PROPERTIES="tomcat.home=/usr/share/tomcat-5.5\ntomcat.password=password\ntomcat.url=http://localhost:8080\ntomcat.username=ide"
	SERVER_PACKAGE="www-servers/tomcat-5.5"
	config_server
	einfo
	einfo "You still need to add"
	einfo "<user username=\"ide\" password=\"password\" roles=\"manager\"/>"
	einfo "to /etc/tomcat-5.5/tomcat-users.xml to be able to deploy applications from Netbeans."
}

config_jboss4() {
        SERVER_NAME="JBoss 4"
        INSTANCE_CONFIG="        <attr name=\"deploy-dir\" stringvalue=\"/usr/share/jboss-4/server/default/deploy\"/>
        <attr name=\"displayName\" stringvalue=\"JBoss Application Server 4\"/>
        <attr name=\"host\" stringvalue=\"localhost\"/>
        <attr name=\"password\" stringvalue=\"\"/>
        <attr name=\"port\" stringvalue=\"8080\"/>
        <attr name=\"root-dir\" stringvalue=\"/usr/share/jboss-4\"/>
        <attr name=\"server\" stringvalue=\"default\"/>
        <attr name=\"server-dir\" stringvalue=\"/usr/share/jboss-4/server/default\"/>
        <attr name=\"url\" stringvalue=\"jboss-deployer:localhost:8080#default&amp;/usr/share/jboss-4\"/>
        <attr name=\"username\" stringvalue=\"\"/>"
        PROPERTIES_FILE="config/J2EE/jb.properties"
        PROPERTIES="#\n#Tue Nov 21 23:34:10 CET 2006\ninstallRoot=/usr/share/jboss-4"
        SERVER_PACKAGE="www-servers/jboss-4"
	config_server
}

# These variables must be set before this function is called:
#        SERVER_NAME
#        INSTANCE_CONFIG
#        PROPERTIES_FILE
#        PROPERTIES
#        SERVER_PACKAGE
# See config_tomcat55 for content.

config_server() {
        einfo "Gentoo Netbeans 6.0 Configuration Utility - ${SERVER_NAME} Configuration"
        einfo
        einfo "Provide path to your Netbeans home dir."
        einfo "Default is [${HOME}/.netbeans/dev]:"
        read USERDIR
        if [ -z "${USERDIR}" ]; then
                USERDIR="${HOME}/.netbeans/dev"
        fi

        FILE="${USERDIR}/config/J2EE/InstalledServers/.nbattrs"
        if [ ! -d "${USERDIR}/config/J2EE/InstalledServers" ]; then
                mkdir -p ${USERDIR}/config/J2EE/InstalledServers
        fi

	if [ ! -f "${FILE}" ]; then
                echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE attributes PUBLIC \"-//NetBeans//DTD DefaultAttributes 1.0//EN\" \"http://www.netbeans.org/dtds/attributes-1_0.dtd\">\n<attributes version=\"1.0\">\n</attributes>" > ${FILE}
	fi

        EXISTS=`grep "\"${SERVER_NAME}\"" ${FILE}`
        if [ -n "${EXISTS}" ]; then
                ewarn
                ewarn "Netbeans configuration file already contains \"${SERVER_NAME}\" configuration. Doing nothing."
        else
                get_j2ee_instance ${FILE}

                sed -i -e "s%</attributes>%%" ${FILE}
		get_j2ee_instance
		echo "    <fileobject name=\"${INSTANCE}\">" >> ${FILE}
                echo ${INSTANCE_CONFIG} >> ${FILE}
		echo -e "    </fileobject>\n</attributes>" >> ${FILE}
		touch ${USERDIR}/config/J2EE/InstalledServers/${INSTANCE}

                echo -e ${PROPERTIES} > ${USERDIR}/${PROPERTIES_FILE}

                einfo
                einfo "Netbeans has been configured for ${SERVER_NAME}."

		if ! portageq has_version / =${SERVER_PACKAGE}*; then
                        ewarn "You do not have ${SERVER_NAME} emerged. Run"
                        ewarn "emerge =${SERVER_PACKAGE}*"
                        ewarn "to have ${SERVER_NAME} installed."
                fi
        fi	
}

get_j2ee_instance() {
	INSTANCE_FILE="${USERDIR}/config/J2EE/InstalledServers/.nbattrs"
	INSTANCE=`grep "\"instance\"" ${INSTANCE_FILE}`
	if [ -z "${INSTANCE}" ]; then
		INSTANCE="instance"
	else
		COUNTER=0
		while [ -n "${INSTANCE}" ]; do
			COUNTER=$((${COUNTER} + 1))
			INSTANCE=`grep "\"instance_${COUNTER}\"" ${INSTANCE_FILE}`
		done
		INSTANCE="instance_${COUNTER}"
	fi
}

case ${1} in
	ant)
	config_ant
	;;

	lm)
	config_lm
	;;

	tomcat55)
	config_tomcat55
	;;

	jboss4)
	config_jboss4
	;;

	*)
	display_usage
	;;
esac
