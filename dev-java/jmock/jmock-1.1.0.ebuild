# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jmock/jmock-1.0.1.ebuild,v 1.5 2005/09/10 16:15:47 axxo Exp $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Library for testing Java code using mock objects."
SRC_URI="http://www.${PN}.org/${P}-src.zip"
HOMEPAGE="http://jmock.codehaus.org"
LICENSE="BSD"
SLOT="1.1"
KEYWORDS="~x86 ~amd64"
IUSE="doc examples"

RDEPEND=">=virtual/jre-1.4
	=dev-java/cglib-2.0*"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${RDEPEND}
	dev-java/ant-core"
src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/jmock-1.1.0-buildxml.patch

	cd ${S}/lib
	rm -f *.jar
	java-pkg_jar-from cglib-2
}

src_compile() {
	local antflags="core.jar cglib.jar"
	use doc && antflags="${antflags} javadoc"
	eant ${antflags} || die "failed to build"
}

src_install() {
	java-pkg_dojar build/dist/jars/*.jar
	dodoc CHANGELOG

	use doc && java-pkg_dohtml -r build/javadoc/*
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r examples/* ${D}/usr/share/doc/${PF}/examples
	fi
}
