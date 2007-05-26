# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-crypto/gnu-crypto-2.0.1-r1.ebuild,v 1.3 2005/07/25 11:16:21 dholm Exp $

inherit java-pkg-2 eutils

DESCRIPTION="GNU Crypto cryptographic primitives for Java"
HOMEPAGE="http://www.gnu.org/software/gnu-crypto/"
SRC_URI="ftp://ftp.gnu.org/gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-*"
# doc
IUSE="source"

# Needs javax.security.sasl which is not in 1.4
DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5"

RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"

# seems to bundle gnu-getopt which we should remove if this is to ever make the
# tree
#	epatch "${FILESDIR}/${PN}-2.0.1-jdk15.patch"
#	epatch "${FILESDIR}/${PN}-2.0.1-clone-exception.patch"
}

src_compile() {
	# jikes support disabled, doesnt work: #86655
	econf JAVAC="javac" JAVACFLAGS="$(java-pkg_javac-args)" --with-jce=yes --with-sasl=yes || die
	emake -j1 || die
#   Target is gone in this version
#	if use doc ; then
#		emake -j1 javadoc || die
#	fi
}

src_install() {
	einstall || die
	rm ${D}/usr/share/*.jar || die

	java-pkg_dojar source/*.jar

#	use doc && java-pkg_dojavadoc api
	use source && java-pkg_dosrc ./source/gnu

	dodoc AUTHORS ChangeLog NEWS README THANKS || die
}
