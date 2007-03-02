# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 java-maven-2 base

HOMEPAGE="http://maven.apache.org"
SRC_URI="http://gentooexperimental.org/distfiles/${P}-gentoo.tar.bz2"
LICENSE="Apache-2.0"

RDEPEND=">=virtual/jdk-1.4 dev-java/ant-core"
DEPEND="${RDEPEND}"
IUSE="source doc test"

EXPORT_FUNCTIONS src_unpack src_compile src_install

maven-plugin-2_src_unpack() {
	# Use base, so we get some patching magic
	base_src_unpack
	if [[ ${JAVA_MAVEN_VERSION} == "*1*" ]]; then
		java-maven-2_m1_src_unpack
	fi

}

maven-plugin-2_src_compile() {
	EMAVEN_TARGET="java:compile" emaven
}

maven-plugin-2_src_install() {
	maven_newplugin target/${P}.jar ${PN}.jar
}

function maven_newplugin() {
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
}
