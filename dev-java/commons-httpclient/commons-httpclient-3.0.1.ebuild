# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-httpclient/commons-httpclient-3.0-r1.ebuild,v 1.1 2006/07/22 22:51:23 nelchael Exp $

inherit java-pkg-2 java-ant-2 eutils

MY_P=${P/_/-}
DESCRIPTION="The Jakarta Commons HttpClient provides an efficient, up-to-date, and feature-rich package implementing the client side of the most recent HTTP standards and recommendations."
HOMEPAGE="http://jakarta.apache.org/commons/httpclient/index.html"
SRC_URI="mirror://apache/jakarta/commons/httpclient/source/${MY_P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="3"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="doc examples source"

RDEPEND=">=virtual/jre-1.3
	dev-java/commons-logging
	dev-java/commons-codec"

DEPEND=">=virtual/jdk-1.3
	sys-apps/sed
	>=dev-java/ant-core-1.4
	junit? ( dev-java/junit )
	source? ( app-arch/zip )
	${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.patch
	mkdir lib && cd lib
	java-pkg_jar-from commons-logging
	java-pkg_jar-from commons-codec
}

src_compile() {
	eant dist $(use_doc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar dist/${PN}-contrib.jar
	use doc && java-pkg_dohtml -r dist/docs/*
	use source && java-pkg_dosrc src/java/* src/contrib/*

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r src/examples/* ${D}/usr/share/doc/${PF}/examples
	fi
}
