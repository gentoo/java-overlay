# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 flag-o-matic

DESCRIPTION="A selection of libraries for Java"
HOMEPAGE="http://www.matthew.ath.cx/projects/java/"
SRC_URI="http://www.matthew.ath.cx/projects/java/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="source"

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5
	source? (app-arch/zip)"

src_compile() {
	append-ldflags -lc
	append-flags -fPIC
	emake -j1 LDFLAGS="$(raw-ldflags) -shared" JCFLAGS="$(java-pkg_javac-args)"
}

src_install() {
	java-pkg_newjar cgi-0.5.jar cgi.jar
	java-pkg_newjar debug-disable-1.1.jar debug-disable.jar
	java-pkg_newjar debug-enable-1.1.jar debug-enable.jar
	java-pkg_newjar hexdump-0.1.jar hexdump.jar
	java-pkg_newjar io-0.1.jar io.jar
	java-pkg_newjar unix-0.2.jar unix.jar
	java-pkg_doso libcgi-java.so
	java-pkg_doso libunix-java.so
	dodoc COPYING INSTALL changelog README || die
	use source && java-pkg_dosrc cx/
}
