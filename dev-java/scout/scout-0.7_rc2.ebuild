# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator java-utils-2

DESCRIPTION="Apache Scout is an implementation of the JSR 93 (JAXR)"
HOMEPAGE="http://ws.apache.org/scout/index.html"
# at least, it s on my box ! :)
#SRC_URI="http://distfiles.cryptelium.net/gentoo/${PF}.tar.bz2"
SRC_URI="http://dev.gentooexperimental.org/~dreeevil/${PF}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 "
IUSE=""

JDOM_PV="1.0_beta9"
DEPEND=">=virtual/jdk-1.4
		>=dev-java/jdom-${JDOM_PV}
		>=dev-java/juddi-0.9_rc4
		>=dev-java/log4j-1.2.13
"
#"
RDEPEND="${DEPEND} >=virtual/jre-1.4"
S=${WORKDIR}/${PN}

EANT_BUILD_TARGET="dist" 

src_unpack(){
	unpack ${A}

	# getting dependencies
	cd ${S}|| die "src_compile: cannot cd to srcdir"
	java-pkg_jar-from jdom-${JDOM_PV}
	java-pkg_jar-from juddi
	java-pkg_jar-from log4j
	cp -f ${FILESDIR}/${PV}/build.xml .||die "src_compile: cannot import ant build file"

}




