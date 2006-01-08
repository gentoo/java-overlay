# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: nichoj
# Purpose: 
#

inherit java-pkg java-utils base

ECLASS="java-maven"
INHERITED="$INHERITED $ECLASS"

DEPEND="~dev-java/maven-gentoo-repo"

JAVA_MAVEN_VERSION=${JAVA_MAVEN_VERSION:=1}

# This is safe to do, right?
case "${JAVA_MAVEN_VERSION}" in
	"1") 
		JAVA_MAVEN_SYSTEM_HOME="/usr/share/maven"
		JAVA_MAVEN_EXEC="${JAVA_MAVEN_SYSTEM_HOME}/bin/maven"
		;;
	"2") 
		JAVA_MAVEN_SYSTEM_HOME="/usr/share/maven-bin-2" 
		JAVA_MAVEN_EXEC="${JAVA_MAVEN_SYSTEM_HOME}/bin/mvn"
		;;
esac

JAVA_MAVEN_SYSTEM_PLUGINS="${JAVA_MAVEN_SYSTEM_HOME}/plugins"
JAVA_MAVEN_SYSTEM_BIN="${JAVA_MAVEN_SYSTEM_HOME}/bin"
JAVA_MAVEN_SYSTEM_LIB="${JAVA_MAVEN_SYSTEM_HOME}/lib"

JAVA_MAVEN_BUILD_HOME=${JAVA_MAVEN_BUILD_HOME:="${T}/.maven"}
JAVA_MAVEN_BUILD_REPO=${JAVA_MAVEN_BUILD_REPO:="${JAVA_MAVEN_BUILD_HOME}/repository"}
JAVA_MAVEN_BUILD_PLUGINS=${JAVA_MAVEN_BUILD_PLUGINS:="${JAVA_MAVEN_BUILD_HOME}/plugins"}

JAVA_MAVEN_PLUGINS=${JAVA_MAVEN_PLUGINS:="jar pom java javadoc test license xdoc"}

emaven() {
	local maven_flags="-Dmaven.repo.local=${JAVA_MAVEN_BUILD_REPO}"
	maven_flags="${maven_flags} -Dmaven.plugin.dir=${JAVA_MAVEN_BUILD_PLUGINS}"
	maven_flags="${maven_flags} -Dmaven.repo.remote=file://usr/share/maven-gentoo-repo"
	maven_flags="${maven_flags} -Dmaven.home.local=${JAVA_MAVEN_BUILD_HOME}"
	maven_flags="${maven_flags} -Dmaven.compile.source=$(java-maven_get-source)"
	maven_flags="${maven_flags} -Dmaven.compile.target=$(java-maven_get-target)"
	/usr/share/maven/bin/maven ${maven_flags} "$@" || die "maven failed"
}


java-maven_use-plugin() {
	JAVA_MAVEN_PLUGINS="${JAVA_MAVEN_PLUGINS} $@"
}

java-maven_src_unpack() {
	einfo "Populating ${JAVA_MAVEN_BUILD_PLUGINS}"
	mkdir -p ${JAVA_MAVEN_BUILD_PLUGINS} || die "mkdir failed"
	cd ${JAVA_MAVEN_BUILD_PLUGINS}

	for plugin in ${JAVA_MAVEN_PLUGINS}; do
		java-pkg_jar-from maven-${plugin}-plugin-${JAVA_MAVEN_VERSION}
	done

	cd -

	base_src_unpack
}

java-maven_get-target() {
#	if [[ -n "$(declare -f java-pkg_get-target)" ]]; then
#		echo $(java-pkg_get-target)
#	else
		echo "1.4"
#	fi
}

java-maven_get-source() {
#	if [[ -n "$(declare -f java-pkg_get-source)" ]]; then
#		echo $(java-pkg_get-source)
#	else
		echo "1.4"
#	fi
}

EXPORT_FUNCTIONS src_unpack

function java-maven_doplugin() {
	# TODO check args
	local plugin_jar=${1}
	local plugin_basename=$(basename ${1})

	java-pkg_dojar ${plugin_jar}

	local jardir
	if [[ ${SLOT} != "0" ]]; then
		jardir="/usr/share/${PN}-${SLOT}/lib"
	else
		jardir="/usr/share/${PN}/lib"
	fi
	local installed_jar="${jardir}/${plugin_basename}"

	dodir "${JAVA_MAVEN_SYSTEM_PLUGINS}"
	dosym "${installed_jar}" \
		"${JAVA_MAVEN_SYSTEM_PLUGINS}/${plugin_basename}"
}

# TODO reduce redunancy of doplugin/newplugin

function java-maven_newplugin() {
	# TODO check args
	local plugin_jar=${1}
	local plugin_basename=$(basename ${1})
	local plugin_newjar="${2}"

	java-pkg_newjar ${plugin_jar} ${plugin_newjar}

	local jardir
	if [[ ${SLOT} != "0" ]]; then
		jardir="/usr/share/${PN}-${SLOT}/lib"
	else
		jardir="/usr/share/${PN}/lib"
	fi
	local installed_jar="${jardir}/${plugin_newjar}"

	dodir "${JAVA_MAVEN_SYSTEM_PLUGINS}"
	dosym "${installed_jar}" \
		"${JAVA_MAVEN_SYSTEM_PLUGINS}/${plugin_basename}"
}
