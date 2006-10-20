# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-logging/commons-logging-1.0.4-r2.ebuild,v 1.2 2006/07/22 21:23:55 nelchael Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="The Jakarta-Commons Logging package is an ultra-thin bridge between different logging libraries."
HOMEPAGE="http://jakarta.apache.org/commons/logging/"
SRC_URI="mirror://apache/jakarta/commons/logging/source/${P}-src.tar.gz"

LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="avalon-logkit log4j servletapi avalon-framework doc source"

RDEPEND=">=virtual/jre-1.3
	avalon-logkit? ( =dev-java/avalon-logkit-1.2* )
	log4j? ( =dev-java/log4j-1.2* )
	servletapi? ( =dev-java/servletapi-2.3* )
	avalon-framework? ( =dev-java/avalon-framework-4.2* )"
# ATTENTION: Add this when log4j-1.3 is out
#	=dev-java/log4j-1.3*
DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core
	source? ( app-arch/zip )
	${RDEPEND}"

S="${WORKDIR}/${P}-src/"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.patch
	# patch to make the build.xml respect no servletapi
	epatch ${FILESDIR}/${P}-servletapi.patch

	use log4j && echo "log4j12.jar=$(java-pkg_getjars log4j)" > build.properties
	# ATTENTION: Add this when log4j-1.3 is out (check the SLOT)
	#echo "log4j13.jar=$(java-pkg_getjars log4j-1.3)" > build.properties
	use avalon-logkit && echo "logkit.jar=$(java-pkg_getjars avalon-logkit-1.2)" >> build.properties
	use servletapi && echo "servletapi.jar=$(java-pkg_getjars servletapi-2.3)" >> build.properties
	use avalon-framework && echo "avalon-framework.jar=$(java-pkg_getjars avalon-framework-4.2)" >> build.properties
}

src_compile() {
	eant compile
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
	java-pkg_newjar target/${PN}-api-${PV}.jar ${PN}-api.jar
	java-pkg_newjar target/${PN}-adapters-${PV}.jar ${PN}-adapters.jar

	dodoc RELEASE-NOTES.txt
	dohtml PROPOSAL.html STATUS.html
	use doc && java-pkg_dohtml -r target/docs/
	use source && java-pkg_dosrc src/java/org
}
