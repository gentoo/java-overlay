# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jdbc-mysql/jdbc-mysql-3.0.16.ebuild,v 1.4 2005/07/25 14:39:03 axxo Exp $

inherit java-pkg

DESCRIPTION="Connector/J: A MySQL JDBC connector"
HOMEPAGE="http://dev.mysql.com/downloads/connector/j/3.0.html"
SRC_URI="mirror://mysql/Downloads/Connector-J/mysql-connector-java-${PV}-ga.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~ppc amd64 ~sparc"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/junit
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.3"

S=${WORKDIR}/mysql-connector-java-${PV}-ga

src_compile() {
	ant || die "Failed to compile"
}

src_install() {
	java-pkg_dojar mysql-connector-java-${PV}-ga-bin.jar

	dodoc COPYING CHANGES README
	use doc && cp docs/connector-j-en.pdf ${D}/usr/share/doc/${PF}/
}
