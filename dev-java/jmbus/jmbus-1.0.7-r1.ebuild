# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2

DESCRIPTION="Java Message Bus (RFC 3259) library"
HOMEPAGE="http://www.mbus.org/"
SRC_URI="ftp://ftp.informatik.uni-bremen.de/home/prelle/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4
	sys-devel/libtool
	dev-util/pkgconfig"
RDEPEND=">=virtual/jre-1.4"

src_compile() {
	./configure \
		--host=${CHOST} \
		--prefix=/usr \
		--infodir=/usr/share/info \
		--mandir=/usr/share/man || die "./configure failed"
	emake || die
}

src_install() {
	java-pkg_dojar src/jmbus.jar
	insinto /usr/lib/pkgconfig
	doins src/jmbus.pc
	dobin jmspy.sh
	dobin jmbuskeygen.sh
	dobin jcetest.sh
	dodoc AUTHORS README TODO
}

