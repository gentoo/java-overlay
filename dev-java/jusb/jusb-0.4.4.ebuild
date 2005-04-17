# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg linux-info

DESCRIPTION="jUSB provides a Free Software Java API for USB"

HOMEPAGE="http://jusb.sourceforge.net/"

SRC_URI="mirror://sourceforge/${PN}/${P}-src.tgz"

LICENSE="LGPL-2.1"

SLOT="0"

KEYWORDS="~x86"

IUSE="doc"

DEPEND="virtual/jdk"

RDEPEND="virtual/jre"

CONFIG_CHECK="USB_DEVICEFS"

ERROR_CONFIG_USB_DEVICEFS="

You need to turn on the USB device filesystem
option under USB support in order to use jUSB
" 

src_unpack() {
	mkdir ${P}
	cd ${P}
	unpack ${A}
	mkdir src
	tar -xzf src.tgz -C src || die \
	"failed to unpack sources"
	
	epatch ${FILESDIR}/native.patch
	epatch ${FILESDIR}/Makefile.patch
}

src_compile() {
	export OSTYPE="linux-gnu"

	make || die "Failed to compile"

	if use doc; then 
		make javadoc || die "Failed to create javadoc" 
	fi
}

src_install() {
	java-pkg_dojar jusb.jar
	java-pkg_sointo /usr/lib
	java-pkg_doso libjusb.so

	dodoc LICENSE README*

	if use doc; then
		java-pkg_dohtml doc/*.html
		java-pkg_dohtml -r apidoc/*
	fi
}
