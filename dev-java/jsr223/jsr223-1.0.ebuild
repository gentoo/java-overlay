# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jsr101/jsr101-1.1.ebuild,v 1.5 2007/12/05 19:59:50 nelchael Exp $

JAVA_PKG_IUSE=""

inherit java-pkg-2

DESCRIPTION="Scripting for the Java(TM) Platform"
HOMEPAGE="http://jcp.org/en/jsr/detail?id=223"
SRC_URI="sjp-1_0-fr-ri.zip"

LICENSE="sun-bcla-jsr223"
RESTRICT="fetch"
SLOT="0"
KEYWORDS="amd64 ~ppc x86 ~x86-fbsd"

IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND="app-arch/unzip"

S="${WORKDIR}"

pkg_nofetch() {

	einfo "Please go to:"
	einfo " http://jcp.org/en/jsr/detail?id=223"
	einfo "then click on Download button in Reference Implementation and Technology Compatibility Kit"
	einfo "section and download file:"
	einfo " ${SRC_URI}"
	einfo "and place it in:"
	einfo " ${DISTDIR}"

}

src_compile() {
	:
}

src_install() {
	java-pkg_dojar script-api.jar
}
