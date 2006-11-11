# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/itext/itext-1.4.5.ebuild,v 1.1 2006/09/28 00:36:59 wltjr Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java library that generate documents in the Portable Document Format (PDF) and/or HTML."
HOMEPAGE="http://www.lowagie.com/iText/"
SRC_URI="http://www.lowagie.com/iText/build.xml
		mirror://sourceforge/itext/${PN}-src-${PV}.tar.gz
		http://itext.sourceforge.net/downloads/iTextHYPH.jar"

IUSE="doc source"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_unpack() {
	mkdir ${WORKDIR}/src && cd ${WORKDIR}/src
	unpack ${PN}-src-${PV}.tar.gz
	cp ${DISTDIR}/build.xml ${WORKDIR}
	cp ${DISTDIR}/iTextHYPH.jar ${WORKDIR}
}

src_compile() {
	eant compileWithXML jarWithXML $(use_doc)
}

src_install() {
	java-pkg_dojar dist/*
	java-pkg_dojar iTextHYPH.jar

	use source && java-pkg_dosrc src/com
	use doc && java-pkg_dojavadoc docs
}
