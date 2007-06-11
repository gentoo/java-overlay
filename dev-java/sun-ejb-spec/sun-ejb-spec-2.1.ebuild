# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-ejb-spec/sun-ejb-spec-2.1.ebuild,v 1.2 2006/01/22 14:58:33 nichoj Exp $

inherit java-pkg-2 versionator

MY_PN=ejb
MY_PV=$(replace_all_version_separators _)
MY_P="${MY_PN}-${MY_PV}"
At="${MY_P}-fr-spec-api.zip"
DESCRIPTION="Sun's Enterprise Java Beans specification"
HOMEPAGE="http://java.sun.com/products/ejb/"
SRC_URI="${At}"
DOWNLOAD_URL="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=ejb-${PV}-fr-class-oth-JSpec&SiteId=JSC&TransactionId=noreg"

LICENSE="sun-ejb-spec-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND="app-arch/unzip"
RESTRICT="fetch"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download ${A} from the following URL and place it in ${DISTDIR}:"
	einfo "${DOWNLOAD_URL}"
}


src_install() {
	java-pkg_newjar ${MY_P}-api.jar ${MY_PN}-api.jar
}
