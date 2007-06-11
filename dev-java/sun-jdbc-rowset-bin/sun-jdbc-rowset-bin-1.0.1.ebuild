# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

# Would it hurt sun to label things consistently...?
MY_PN="jdbc_rowset_tiger"
MY_PV="${PV//./_}-mrel-ri"
MY_P="${MY_PN}-${MY_PV}"
DESCRIPTION="JDBC Rowset for Java releases prior to 1.5"
HOMEPAGE="http://java.sun.com/products/jdbc/"
SRC_URI="https://sdlcweb3c.sun.com/ECom/EComActionServlet;jsessionid=30F646A663A4F3E3C1D042C56374E99C#http://192.18.97.120/ECom/EComTicketServlet/BEGIN30F646A663A4F3E3C1D042C56374E99C/-2147483648/914138883/1/495722/495710/914138883/2ts+/westCoastFSEND/${MY_P}-oth-JPR/${MY_P}-oth-JPR:1/${MY_P}.zip"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"
RESTRICT="fetch"

DEPEND="app-arch/unzip"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}/${MY_PN}${PV}mrel-ri"

pkg_nofetch() {
	einfo "Visit http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=jdbc_rowset_tiger-1_0_1-mrel-ri-oth-JPR&SiteId=JCP&TransactionId=noreg"
	einfo "Accept the agreement, and download jdbc_rowset_tiger-1_0_1-mrel-ri.zip"
	einfo "Copy ${MY_P}.zip to ${DISTDIR}"
}

src_unpack() {
	unpack ${A}
	cd ${S}
	mv doc api
}

src_install() {
	java-pkg_dojar rowset.jar
	use doc && java-pkg_dojavadoc api
}
