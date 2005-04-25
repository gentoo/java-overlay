# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils linux-info

DESCRIPTION="Java(tm) Binary Kernel Support for Linux"
HOMEPAGE="http://www.linuxhq.com/java.html"
SRC_URI="mirror://gentoo/java-kernel-support-gentoo-20050425.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
DEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${PN}

CONFIG_CHECK="BINFMT_MISC"
ERROR_BINFMT_MISC="

You need to have 'Kernel support for MISC binaries' 
turned on in your kernel config. It can be either 
compile in or as a module.
"
src_compile() {
	gcc ${CFLAGS} javaclassname.c -o javaclassname || die "Failed to compile"
}

src_install() {
	dobin javawrapper jarwrapper javaclassname
}
