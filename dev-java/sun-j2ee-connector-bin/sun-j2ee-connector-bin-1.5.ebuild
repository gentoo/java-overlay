# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

At="j2ee_connector-${PV//./_}-fr-spec-classes.zip"
DESCRIPTION="The J2EE Connector architecture provides a Java solution to the problem of connectivity between the many application servers and EISs already in existence"
HOMEPAGE="http://java.sun.com/j2ee/connector/"
SRC_URI="${At}"
DOWNLOAD_URL="http://java.sun.com/j2ee/connector/download.html"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch"

DEPEND="app-arch/unzip"
RDEPEND="virtual/jre"

pkg_nofetch() {
	einfo " "
	einfo " Due to license restrictions, we cannot fetch the"
	einfo " distributables automagically."
	einfo " "
	einfo " 1. Visit ${DOWNLOAD_URL}, and click Download class file... continue"
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
	mkdir ${S}
	cd ${S}
	unpack ${A}
}

src_compile() {
	true
}

src_install() {
	java-pkg_dojar *.jar
}
