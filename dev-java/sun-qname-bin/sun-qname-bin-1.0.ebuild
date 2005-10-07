# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_P="jax-${PV/./_}-fr-qname"
At="${MY_P}-class.zip"
DESCRIPTION="javax.xml.namespace.QName API Specification Interface Classes 1.0 Final Release"
HOMEPAGE="http://java.sun.com/xml/downloads/jaxrpcarchive.html"
SRC_URI="${At}"
RESTRICT="fetch"

LICENSE="sun-bcla-qname"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="virtual/jre"
DOWNLOAD_URL="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=7751-javax_qname-1.0-fr-class-oth-JSpec&SiteId=JSC&TransactionId=noreg"

S=${WORKDIR}

pkg_nofetch() {
	einfo " "
	einfo " Due to license restrictions, we cannot fetch the"
	einfo " distributables automagically."
	einfo " "
	einfo " 1. Visit ${HOMEPAGE}"
	einfo "   Direct link: ${DOWNLOAD_URL}"
	einfo " 2. Download ${At}"
	einfo " 3. Move file to ${DISTDIR}"
	einfo " "
}

src_unpack() {
	if [ ! -f "${DISTDIR}/${At}" ] ; then
		echo  " "
		echo  "!!! Missing ${DISTDIR}/${At}"
		echo  " "
		einfo " "
		einfo " Due to license restrictions, we cannot fetch the"
		einfo " distributables automagically."
		einfo " "
		einfo " 1. Visit ${HOMEPAGE}"
		einfo " 2. Download ${At}"
		einfo " 3. Move file to ${DISTDIR}"
		einfo " 4. Run emerge on this package again to complete"
		einfo " "
		die "User must manually download distfile"
	fi
	unpack ${A}
}

src_install() {
	java-pkg_dojar jax-qname.jar
}
