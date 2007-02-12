# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator java-utils-2

DESCRIPTION="Apache Scout is an implementation of the JSR 93 (JAXR)"
HOMEPAGE="http://ws.apache.org/scout/index.html"
# at least, it s on my box ! :)
#SRC_URI="http://distfiles.cryptelium.net/gentoo/${PF}.tar.bz2"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${PF}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 "
IUSE="doc source examples"

JDOM_SLOT="1.0_beta9"
DEPEND=">=virtual/jdk-1.4
		>=dev-java/jdom-${JDOM_SLOT}
		>=dev-java/juddi-0.9_rc4
		>=dev-java/log4j-1.2.13
		>=dev-java/commons-logging-1.0.4-r1
		>=dev-java/junit-3.8.2
		>=www-servers/axis-1.2_rc2
		>=dev-java/commons-discovery-0.2-r2
		>=dev-java/sun-javamail-1.4
"
RDEPEND="${DEPEND} >=virtual/jre-1.4"
S=${WORKDIR}/${PN}

EANT_BUILD_TARGET="dist"

src_unpack(){
	unpack ${A}
	cd "${S}"
	# getting  Dependencies
	java-pkg_jar-from jdom-${JDOM_SLOT}
	java-pkg_jar-from juddi
	java-pkg_jar-from log4j
	java-pkg_jar-from junit
	java-pkg_jar-from commons-logging
	java-pkg_jar-from axis-1
	java-pkg_jar-from commons-discovery
	java-pkg_jar-from sun-javamail
	cp -f ${FILESDIR}/${PV}/build.xml .||die "src_compile: cannot import ant build file"

}


src_install() {
	java-pkg_newjar dist/lib/${PN}.jar
	use doc && java-pkg_dojavadoc dist/docs
	use source && java-pkg_dosrc modules/jaxr-api/src/java/
	use source && java-pkg_dosrc    modules/scout/src/java/
	if use examples; then
			dodir /usr/share/doc/${PF}/examples
			cp -r src/samples/* ${D}/usr/share/doc/${PF}/examples
	fi
}


