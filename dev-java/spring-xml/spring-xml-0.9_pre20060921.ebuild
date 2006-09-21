# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PV=${PV/_pre*/-SNAPSHOT}
DESCRIPTION="Spring tools for using Castor XML"
HOMEPAGE="http://www.castor.org"
SRC_URI="http://dev.gentoo.org/~nichoj/distfiles/${P}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="source"

COMMON_DEPS="
	=dev-java/spring-1*
	=dev-java/castor-1.0*
	dev-java/commons-logging
"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	source? ( app-arch/zip )
	${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPS}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd ${S}/lib
	java-pkg_jar-from castor-1.0 castor-xml.jar
	java-pkg_jar-from spring spring-beans.jar
	java-pkg_jar-from spring spring-core.jar
	java-pkg_jar-from spring spring-context.jar
	java-pkg_jar-from commons-logging commons-logging-api.jar
}

src_compile() {
	eant jar
}

src_install() {
	java-pkg_newjar target/${PN}-${MY_PV}.jar
	use source && java-pkg_dosrc src/main/java/org

}
