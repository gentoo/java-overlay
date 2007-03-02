# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Original Author: Joshua Nichols <nichoj@gentoo.org>
# Migrated to -2 by kiorky kiorky@¢ryptelium.net
# Purpose: facilitate packaging commons-jellyt-tags-*

# Procedure for packaging common-jelly-tags:
# * Go to the SVN repository located at:
# 		http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/
# 	You'll probably want to use things that are tagged, so:
#		http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/
# * For whatever set to package, from the repository, figure out where the
# 	source actually lives in the repository.
#		ie for log, it'd be http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/COMMONS-JELLY-LOG-1_0/jelly-tags/log/
# * Make a checkout of the source to ${P}
# * Make a patch to the build.xml to remove deps: 'get-deps' from compile, and 'test' from
# * Run 'ant get-deps', to figure out what it depends on.
# * For everything that isn't part of LDEPEND below, add it to RDEPEND of the
# 	ebuild
# * If there is anything isn't part of LDEPEND below, also declare a function
#	commons-jelly-tags_src_unpack(), and make the appropriate java-pkg_jar-from
#	calls
# * ant clean
# * Create a tarball of the checkout as ${P}.tar.bz2

WANT_ANT_TASKS="ant-junit"

inherit java-pkg-2 java-ant-2 java-maven-2

DECRIPTION="An Executable XML Java Elements Framework"
HOMEPAGE="http://jakarta.apache.org/commons/jelly/"
SLOT=${SLOT:=${PV}}
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"
COMMON_DEPS="dev-java/commons-jelly
			=dev-java/commons-beanutils-1.6*
			dev-java/commons-collections
			=dev-java/commons-jexl-1.0*
			dev-java/commons-logging
			dev-java/commons-lang
			=dev-java/dom4j-1*
			=dev-java/jaxen-1.1*
			>=dev-java/xerces-2.7
			dev-java/junit"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS} ${DEPEND}"
DEPEND=">=virtual/jdk-1.4  ${COMMON_DEPS} ${DEPEND}
		source? ( app-arch/zip )"
IUSE="doc source test"
LICENSE="Apache-2.0"

LEANT_GENTOO_CLASSPATH="commons-jelly-1
			commons-beanutils-1.6
			commons-cli-1
			commons-collections
			commons-logging
			commons-lang
			commons-jexl-1.0
			dom4j-1
			jaxen-1.1
			junit
			xerces-2"
EANT_DOC_TARGET="javadoc"
EANT_BUILD_TARGET="compile jar"
EANT_EXTRA_FLAGS="-Dfinal.name=${PN}"

EXPORT_FUNCTIONS src_unpack src_compile src_install src_test


commons-jelly-tags-2_src_unpack() {
	unpack ${A}
	java-maven-2-rewrite_build_xml
}

# Pull jars that will be used by all commons-jelly-tags packages
commons-jelly-tags-2_set_gcp() {
	if [[ -n ${EANT_GENTOO_CLASSPATH} ]]; then
		EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH},${LEANT_GENTOO_CLASSPATH}"
	else
		EANT_GENTOO_CLASSPATH="${LEANT_GENTOO_CLASSPATH}"
	fi
}

commons-jelly-tags-2_src_compile() {
	commons-jelly-tags-2_set_gcp
	java-pkg-2_src_compile
}

commons-jelly-tags-2_src_install() {
	java-pkg_newjar target/*.jar ${PN}.jar
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}

commons-jelly-tags-2_src_test() {
	commons-jelly-tags-2_set_gcp
	einfo $EANT_GENTOO_CLASSPATH
	eant test || die "Tests failed"
}
