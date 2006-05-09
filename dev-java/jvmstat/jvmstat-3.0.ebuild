# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 versionator

MY_PV=$(replace_version_separator 1 '_')
DESCRIPTION="A set of monitoring APIs and tools for monitoring the performance of the JVM in production environments."
HOMEPAGE="http://java.sun.com/performance/jvmstat/"
SRC_URI="jvmstat-${MY_PV}.zip"

LICENSE="sun-bcla-jvmstat"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

RESTRICT="fetch nostrip"

DEPEND=""
RDEPEND=">=virtual/jre-1.5*"

S="${WORKDIR}/jvmstat/"

INSTTO="/opt/${PN}"

pkg_nofetch() {

	einfo "Please go to following URL:"
	einfo " ${HOMEPAGE}"
	einfo "download file named ${SRC_URI} and place it in:"
	einfo " ${DISTDIR}"

}

src_install() {

	dodir "${INSTTO}"
	cd "${S}"
	cp -r jars bin ${D}/${INSTTO}

	dodoc README
	use doc && dodoc -r docs

}
