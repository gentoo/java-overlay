# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="${PN//jboss-/}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="The Jakarta-Commons Logging package is an ultra-thin bridge between different logging libraries. JBoss modified"
HOMEPAGE="http://jakarta.apache.org/commons/logging/"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="avalon-logkit log4j servletapi avalon-framework doc source"

RDEPEND=">=virtual/jre-1.3
	avalon-logkit? ( =dev-java/avalon-logkit-1.2* )
	log4j? ( =dev-java/log4j-1.2* )
	servletapi? ( =dev-java/servletapi-2.3* )
	avalon-framework? ( =dev-java/avalon-framework-4.2* )"

# ATTENTION: Add this when log4j-1.3 is out
#	=dev-java/log4j-1.3*
DEPEND=">=virtual/jdk-1.3
	source? ( app-arch/zip )
	${RDEPEND}"

EANT_GENTOO_CLASSPATH="junit"
use log4j && EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH},log4j"
use avalon-logkit && EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH},avalon-logkit-1.2"
use servletapi && EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH},servletapi-2.3"
use avalon-framework && EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH},avalon-framework-4.2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch ${FILESDIR}/${P}-gentoo.patch
	# patch to make the build.xml respect no servletapi
	# TODO file upstream -nichoj
	epatch ${FILESDIR}/${P}-servletapi.patch

	# ATTENTION: Add this when log4j-1.3 is out (check the SLOT)
	#echo "log4j13.jar=$(java-pkg_getjars log4j-1.3)" > build.properties
	for build in $(find "${S}" -name build*xml);do
		java-ant_rewrite-classpath $build
	done
}

EANT_BUILD_TARGET="compile"

src_install() {
	java-pkg_newjar target/${MY_P}.jar ${MY_PN}.jar
	java-pkg_newjar target/${MY_PN}-api-${PV}.jar ${MY_PN}-api.jar
	java-pkg_newjar target/${MY_PN}-adapters-${PV}.jar ${MY_PN}-adapters.jar

	dodoc RELEASE-NOTES.txt || die
	dohtml PROPOSAL.html  || die
	use doc && java-pkg_dojavadoc target/docs/
	use source && java-pkg_dosrc src/java/org
}
