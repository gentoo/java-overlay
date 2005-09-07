# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/antlr/antlr-2.7.5.ebuild,v 1.3 2005/07/19 18:46:32 axxo Exp $

inherit java-pkg gnuconfig

DESCRIPTION="A parser generator for Java and C++, written in Java"
SRC_URI="http://www.antlr.org/download/${P}.tar.gz"
HOMEPAGE="http://www.antlr.org"
DEPEND=">=virtual/jdk-1.2
	source? ( app-arch/zip )"
SLOT="0"
LICENSE="ANTLR"
KEYWORDS="~x86 ~amd64 ~ppc64"
IUSE="doc examples source"

src_compile() {
	gnuconfig_update
	econf || die
	make all || die
}

src_install() {
	java-pkg_newjar ${P}.jar ${PN}.jar
	use source && java-pkg_dosrc antlr

	insinto /usr/share/antlr
	doins extras/antlr-mode.el

	dobin scripts/antlr-config

	use doc && java-pkg_dohtml -r doc/*

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r examples/* ${D}/usr/share/doc/${PF}/examples
	fi
	cd lib/cpp
	einstall || die "failed to install"
#	make DESTDIR=$D install || die "failed to install"
}
