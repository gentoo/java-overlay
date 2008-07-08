# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

inherit eutils flag-o-matic

DESCRIPTION="Cacao Java Virtual Machine"
HOMEPAGE="http://www.cacaojvm.org/"
SRC_URI="http://www.complang.tuwien.ac.at/cacaojvm/download/${P}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""
CLASSPATH_SLOT=0.96
DEPEND="dev-java/gnu-classpath:${CLASSPATH_SLOT}"
RDEPEND="${DEPEND}"

CLASSPATH_DIR=/usr/gnu-classpath-${CLASSPATH_SLOT}

src_compile() {
	# Upstream has patches this already so we just use this until the next
	# version
	append-flags -Wa,--noexecstack

	# A compiler can be forced with the JAVAC variable if needed
	unset JAVAC
	econf --bindir=/usr/${P}/bin \
		--disable-dependency-tracking \
		--with-classpath-prefix=${CLASSPATH_DIR} \
		--with-classpath-libdir="${CLASSPATH_DIR}/$(get_libdir)"

	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodir /usr/bin
	dosym /usr/${P}/bin/cacao /usr/bin/cacao
	dodoc AUTHORS ChangeLog* NEWS README || die "failed to install docs"
}
