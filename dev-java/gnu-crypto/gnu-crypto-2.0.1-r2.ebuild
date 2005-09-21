# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-crypto/gnu-crypto-2.0.1-r1.ebuild,v 1.3 2005/07/25 11:16:21 dholm Exp $

inherit java-pkg eutils

DESCRIPTION="GNU Crypto cryptographic primitives for Java"
HOMEPAGE="http://www.gnu.org/software/gnu-crypto/"
SRC_URI="ftp://ftp.gnupg.org/GnuPG/gnu-crypto/gnu-crypto-2.0.1.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ppc ~ppc64 ~x86"
IUSE="doc jikes"

DEPEND=">=virtual/jdk-1.3
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jre-1.3"

RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/${P}-jdk15.patch
}

src_compile() {
	# jikes support disabled, doesnt work: #86655
	local my_javac=${JAVAC}
	use jikes && my_javac="jikes -bootclasspath ${JAVA_HOME}/jre/lib/rt.jar"
	
	JAVAC=${my_javac} econf \
		--with-jce=yes \
		--with-sasl=yes \
		|| die
	emake -j1 || die
	if use doc ; then
		emake -j1 javadoc || die
	fi
}

src_install() {
	einstall || die
	rm ${D}/usr/share/*.jar

	java-pkg_dojar source/gnu-crypto.jar
	java-pkg_dojar jce/javax-crypto.jar
	java-pkg_dojar security/javax-security.jar

	use doc && java-pkg_dohtml -r api/*

	dodoc AUTHORS COPYING ChangeLog INSTALL NEWS README THANKS
}
