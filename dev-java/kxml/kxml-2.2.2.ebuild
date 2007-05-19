# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Some java libary"
HOMEPAGE="http://kxml.sourceforge.net/"

SRC_URI="mirror://sourceforge/${PN}/${PN}2-src-${PV}.zip"
LICENSE="as-is"
SLOT="2"
KEYWORDS="~x86"

IUSE=""

RDEPEND=">=virtual/jre-1.5"

DEPEND=">=virtual/jdk-1.5
	${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	rm dist/*
	#We do not remove the lib/xmlpull_*.jar, the source is avail at
	# http://www.xmlpull.org/v1/download/ but ONLY the latest version
}

EANT_BUILD_TARGET="build_jar"

src_install() {
	java-pkg_newjar dist/${PN}2-${PV}.jar ${PN}2.jar
	use source && java-pkg_dosrc src/*
	use doc && java-pkg_dojavadoc www/kxml2/javadoc
}

