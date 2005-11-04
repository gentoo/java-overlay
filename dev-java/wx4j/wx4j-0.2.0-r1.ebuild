# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/wx4j/wx4j-0.2.0-r1.ebuild,v 1.1 2005/10/02 15:20:00 betelgeuse Exp $

inherit eutils java-pkg

DESCRIPTION="A blending of the wxWindows C++ class library with Java"
HOMEPAGE="http://www.wx4j.org/"
SRC_URI="mirror://sourceforge/wx4j/${P}.tar.bz2"

LICENSE="BSD"
SLOT="1"
KEYWORDS="-amd64 ~x86 ~ppc" #segfaults on amd64
IUSE="examples source"

RDEPEND=">=virtual/jre-1.4
	=x11-libs/wxGTK-2.4*
	=x11-libs/gtk+-2*
	>=x11-libs/pango-1.2
	>=dev-libs/glib-2.0
	=dev-lang/swig-1.3.21*"

DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	dev-util/pkgconfig
	>=dev-java/ant-1.6.2-r6"

src_unpack() {
	unpack ${A}
	cd ${S}

	cp project/build.properties.dist build.properties
	epatch ${FILESDIR}/${P}-build.patch
}

src_compile() {
	local antflags="build"
	ant ${antflags} || die "compilation failed"
}

src_install() {
	java-pkg_dojar dist/wx4j/lib/*.jar
	java-pkg_doso dist/wx4j/lib/libwx4j.so

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r project/samples/java/* ${D}/usr/share/doc/${PF}/examples
	fi

	use source && java-pkg_dosrc project/wx4j/java/*
}
