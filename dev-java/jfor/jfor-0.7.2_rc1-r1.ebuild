# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PV=${PV/_/}
MY_PV=${MY_PV//./_}
MY_P="${PN}-src-V_${MY_PV}"

DESCRIPTION="A Java XSL-FO to RTF converter."
HOMEPAGE="http://www.jfor.org/"
SRC_URI="mirror://sourceforge/jfor/${MY_P}.tar.gz"
# Apache-like but has its own licence with s/Apache/jfor/ basically.
# http://www.jfor.org/jfor-license.html
LICENSE=""
SLOT="0"
KEYWORDS="~x86 ~ppc"
IUSE=""


# TODO remove -bin dep
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	dev-java/xerces
	|| (	dev-java/avalon-logkit
		dev-java/avalon-logkit-bin)"

S=${WORKDIR}/${PN}

src_compile() {
	eant
}

src_install() {
	java-pkg_dojar dist/lib/*.jar
	dobin ${FILESDIR}/jfor
}
