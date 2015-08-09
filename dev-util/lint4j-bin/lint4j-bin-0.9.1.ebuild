# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2
DESCRIPTION="Static Java source and byte code analyzer."
HOMEPAGE="http://www.jutils.com/"
SRC_URI="http://www.jutils.com/download/lint4j/lint4j-0.9.1.tar.gz"
LICENSE="lint4j"
SLOT="0"
KEYWORDS="~x86"
IUSE="examples"
RESTRICT="mirror"

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/lint4j-${PV}

src_install() {
	java-pkg_dojar jars/lint4j.jar
	java-pkg_dolauncher lint4j
	java-pkg_register-ant-task

	dodoc README.txt doc/ACKNOWLEDGEMENTS.txt doc/CHANGELOG.txt

	if use examples ; then
		dodir /usr/share/doc/${PF}/examples
		cp -r examples/* ${D}/usr/share/doc/${PF}/examples || die "Cannot install examples"
	fi
}
