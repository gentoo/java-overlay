# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-j2ee/sun-j2ee-1.3.1-r2.ebuild,v 1.5 2004/11/30 21:41:31 swegener Exp $

inherit java-pkg

DESCRIPTION="Sun's Java 2 Enterprise Edition Development Kit"
SRC_URI="j2sdkee-1_3_1-linux.tar.gz"
HOMEPAGE="http://java.sun.com/j2ee/download.html#sdk"
DEPEND="virtual/libc
		>=sys-libs/lib-compat-1.1"
RDEPEND=">=virtual/jre-1.3.1"
PROVIDE="virtual/j2ee-1.3.1"
LICENSE="sun-bcla-j2ee"
RESTRICT="fetch"
SLOT="0"
KEYWORDS="x86 -ppc"
IUSE="doc"

S=${WORKDIR}/j2sdkee1.3.1

pkg_nofetch() {
	die "Please download ${SRC_URI} from ${HOMEPAGE} to ${DISTDIR}"
}

src_install () {
	local dirs="bin lib conf config cloudscape lib images nativelib repository public_html logs help images xsl"

	dodir /opt/${P}
	for i in $dirs ; do
		cp -a $i ${D}/opt/${P}/
	done

	dodir /etc/env.d/
	local j2eeenv=${D}/etc/env.d/29${P}
	echo "CLASSPATH=/opt/${P}/lib/j2ee.jar" > $j2eeenv
	echo "PATH=/opt/${P}/bin" >> $j2eeenv
	echo "J2EE_HOME=/opt/${P}" >> $j2eeenv
	dodoc LICENSE README

	if use doc ; then
		java-pkg_dohtml -r doc/*
	fi
}

pkg_postinst() {
	einfo "Remember to set JAVA_HOME before running /opt/${P}/bin/j2ee"
	einfo "A set of sample configuration files (that work) can be found in /opt/${P}/conf and /opt/${P}/config"
}
