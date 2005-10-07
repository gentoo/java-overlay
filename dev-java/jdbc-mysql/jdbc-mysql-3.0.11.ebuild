# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jdbc-mysql/jdbc-mysql-3.0.11.ebuild,v 1.5 2005/07/16 16:39:49 axxo Exp $

inherit java-pkg

At=mysql-connector-java-${PV}-stable

DESCRIPTION="MySQL JDBC driver"
HOMEPAGE="http://www.mysql.com"
SRC_URI="mirror://mysql/Downloads/Connector-J/${At}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ppc sparc amd64"
IUSE=""
DEPEND=""
RDEPEND=">=virtual/jre-1.2"

S=${WORKDIR}/${At}

src_compile() { :; }

src_install() {
	java-pkg_dojar ${At}-bin.jar
	dodoc README CHANGES COPYING
}
