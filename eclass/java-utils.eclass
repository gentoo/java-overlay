#
# Helper class for all Java packages
#
# Copyright (c) 2004, Thomas Matthijs <axxo@keanu.be>
# Copyright (c) 2004, Karl Trygve Kalleberg <karltk@gentoo.org>
# Copyright (c) 2004, Gentoo Foundation
#
# Licensed under the GNU General Public License, v2

inherit eutils

ECLASS=java-utils
INHERITED="$INHERITED $ECLASS"
DESCRIPTION="Based on the $ECLASS eclass"

DEPEND=">=dev-java/java-config-1.2.7"
#		>=dev-java/javatoolkit-0.2.0"

EXPORT_FUNCTIONS pkg_setup

java-utils_pkg_setup() {
	java-utils_ensure-jdk

	java-utils_vm-version-sufficient
}

java-utils_setup-vm() {
	local vendor=`java-utils_get-vm-vendor`
	if [ ${vendor} = "sun-jdk" ] && java-utils_is-vm-version-ge 1 5; then
		addpredict "/dev/random"
	elif [[ ${vendor} = "ibm-jdk-bin" ]]; then
		addwrite "/proc/self/maps"
		addwrite "/proc/cpuinfo"
	elif [[ ${vendor} = "jrockit-jdk-bin" ]]; then
		addwrite "/proc/cpuinfo"
	fi
}

java-utils_ensure-jdk() {
	if ! java-utils_is-vm-jdk; then
		eerror "A full JDK is needed by this package. You currently have no Java VM active or only a JRE"
		eerror "Please use java-config -S to set your system vm to a JDK"
		die "Active VM is not a JDK"
	fi
}

java-utils_is-vm-jdk() {
	if [ "$JDK_HOME" ] && [ "$JDK_HOME" == "$JAVA_HOME" ]; then
		return 0
	else
		return 1
	fi
}

java-utils_get-vm-vendor() {
	local vm=$(java-config -f)
	echo ${vm%-*}
}

java-utils_get-vm-version() {
	local version=$(java-config -f | sed -e "s/.*-\([0-9.]\+\).*/\1/")
	echo ${version}
}

java-utils_vm-version-sufficient() {
	local version=$(echo ${DEPEND} | sed -e 's:.*virtual/jdk-\?\([^$ ]*\).*:\1:' -e 's:\.: :g')
	if [ "${version}" != "" ]; then
		java-utils_ensure-vm-version-ge ${version}
	fi
}

java-utils_ensure-vm-version-ge() {
	if ! java-utils_is-vm-version-ge $@ ; then
		eerror "This package requires a Java VM version >= $@"
		einfo "Please use java-config -S to set the correct one"
		die "Active Java VM too old"
	fi
}

java-utils_is-vm-version-ge() {
	local user_major=${1:-0}
	local user_minor=${2:-0}
	local user_patch=${3:-0}
	local user_version=${user_major}.${user_minor}.${user_patch}

	local vm_version=$(java-utils_get-vm-version)

	local vm_major=$(echo ${vm_version} | cut -d. -f1)
	local vm_minor=$(echo ${vm_version} | cut -d. -f2)
	local vm_patch=$(echo ${vm_version} | cut -d. -f3)
	local vm_extra=$(echo ${vm_version} | cut -d. -f4)

	if [ ${vm_major} -ge ${user_major} ] && [ ${vm_minor} -gt ${user_minor} ] ; then
		echo "Detected a JDK >= ${user_version}"
		return 0
	elif [ ${vm_major} -ge ${user_major} ] && [ ${vm_minor} -ge ${user_minor} ] && [ ${vm_patch} -ge ${user_patch} ] ; then
		echo "Detected a JDK >= ${user_version}"
		return 0
	else
		echo "Detected a JDK < ${user_version}"
		return 1
	fi
}

BUILD_XML_LOCATION="/usr/share/javatoolkit/build/"

java-utils_generic-ant () {

	debug-print-function ${FUNCNAME} $*
	
	[ -z "${1}" ] && die "${FUNCNAME}: First argument must be the version number of the build.xml file"

	cp ${BUILD_XML_LOCATION}/build-${1}.xml build.xml

	ant ${@:2} -Dproject.name=${PN} -Dpackage.name=${PN}
}

java-utils_get-generic-ant-script ()
{
	debug-print-function ${FUNCNAME} $*

	[ -z "${1}" ] && die "${FUNCNAME}: First argument must be the version number of the build.xml file"
	
	cp ${BUILD_XML_LOCATION}/build-${1}.xml build.xml
}
