# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
JAVA_PKG_IUSE="doc source"
inherit base java-pkg-2 java-ant-2

DESCRIPTION="Speex speech codec library for Java"
HOMEPAGE="http://jspeex.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/ant-core"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.4
	dev-java/junit
	test? (
		dev-java/ant-junit
		dev-java/ant-trax
	)"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="ant-core"
EANT_BUILD_TARGET="package"
S="${WORKDIR}/${PN}"

java_prepare() {
	cd lib || die
	rm -vf junit*.jar || die
	java-pkg_jar-from --build-only junit
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	dodoc README TODO

	use doc && java-pkg_dojavadoc doc/javadoc
	use source && java-pkg_dosrc src/java/*
}

src_test() {
	ANT_TASKS="ant-junit ant-trax" eant test
}
