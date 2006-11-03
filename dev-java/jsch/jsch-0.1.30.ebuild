# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jsch/jsch-0.1.21-r2.ebuild,v 1.4 2006/10/17 03:38:46 nichoj Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="JSch is a pure Java implementation of SSH2."
HOMEPAGE="http://www.jcraft.com/jsch/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"
LICENSE="jcraft"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86"
IUSE="doc source examples"

RDEPEND=">=virtual/jdk-1.4
	>=dev-java/jzlib-1.0.3
	dev-java/gnu-crypto"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.6
	app-arch/unzip
	source? ( app-arch/zip )
	${RDEPEND}"

src_compile() {
	local antflags="dist $(use_doc)"
	eant -Dproject.cp="$(java-pkg_getjars gnu-crypto,jzlib)" ${antflags}
}

src_install() {
	java-pkg_newjar dist/lib/jsch*.jar jsch.jar
	use doc && java-pkg_dohtml -r javadoc/*
	use source && java-pkg_dosrc src/*
	if use examples; then
		dodir /usr/share/doc/${PF}/examples/
		cp -r examples/* ${D}/usr/share/doc/${PF}/examples/ || die
	fi
	dodoc README ChangeLog
}
