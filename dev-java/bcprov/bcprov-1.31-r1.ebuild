# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN=${PN}-jdk14
MY_PV=${PV//./}
MY_P=${MY_PN}-${MY_PV}

DESCRIPTION="The Bouncy Castle Crypto package is a Java implementation of cryptographic algorithms"
HOMEPAGE="http://www.bouncycastle.org/"
SRC_URI="http://www.bouncycastle.org/download/${MY_P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	dev-java/junit"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${MY_P}

ant_src_unpack() {
	unpack ${A}
	cp ${FILESDIR}/build.xml ${S}
}

src_compile() {
	local junit="$(java-pkg_getjars junit)"
	local antflags="-Dproject.name=${PN} jar -Dclasspath=${junit}"

	eant ${antflags}
	mv docs api
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dohtml *.html
	use doc && java-pkg_dohtml -r api
}
