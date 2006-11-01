# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icu4j/icu4j-3.0-r1.ebuild,v 1.2 2006/10/05 15:45:52 gustavoz Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="International Components for Unicode for Java"

HOMEPAGE="http://icu.sourceforge.net/"
MY_PV=${PV//./_}
SRC_URI="mirror://sourceforge/icu/${PN}src_${MY_PV}.jar
		doc? ( mirror://sourceforge/icu/${PN}docs_${MY_PV}.jar )"
LICENSE="icu"
SLOT="3.4"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc source"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_unpack() {
	jar -xf ${DISTDIR}/${PN}src_${MY_PV}.jar || die "failed to unpack"
	if use doc; then
		mkdir docs; cd docs
		jar -xf ${DISTDIR}/${PN}docs_${MY_PV}.jar || die "failed to unpack docs"
	fi
}

src_compile() {
	eant jar || die "compile failed"
}

src_install() {
	java-pkg_dojar ${PN}.jar

	use doc && java-pkg_dohtml -r readme.html docs/*
	use source && java-pkg_dosrc src/*
}
