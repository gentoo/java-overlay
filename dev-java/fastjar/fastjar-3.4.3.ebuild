# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="A fast implementation of jar"
HOMEPAGE="http://gcc.gnu.org/"
SRC_URI="ftp://gcc.gnu.org/pub/gcc/releases/gcc/gcc-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc ~x86"
IUSE=""

DEPEND=""
RDEPEND="sys-libs/zlib"

S=${WORKDIR}/gcc-${PV}

src_compile() {
	mkdir ${WORKDIR}/build
	cd ${WORKDIR}/build

	# configure from top-level and compile libiberty
	${S}/configure \
	  --host=${CHOST} \
	  --prefix=/usr \
	  --infodir=/usr/share/info \
	  --mandir=/usr/share/man \
	  || die "libiberty config failed"
	make all-libiberty

	# compile fastjar
	mkdir fastjar
	cd fastjar
	${S}/fastjar/configure \
	  --host=${CHOST} \
	  --prefix=/usr \
	  --infodir=/usr/share/info \
	  --mandir=/usr/share/man \
	  --with-system-zlib \
	  || die "fastjar config failed"
	emake || die "emake failed"
}

src_install() {
	cd ${WORKDIR}/build/fastjar
	make DESTDIR=${D} install || die
	(cd ${D}/usr/bin && mv jar fastjar)
	(cd ${D}/usr/share/man/man1 && mv jar.1 fastjar.1)
}
