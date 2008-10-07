# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source test"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Jaminid is a very small (and fast) daemon meant to embed in Java applications as an add-on HTTP interface."
HOMEPAGE="http://jaminid.sourceforge.net/"
SRC_URI="mirror://sourceforge/morfologik/${P}-src.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

COMMON_DEPEND="dev-java/stempel:0
	dev-java/commons-cli:1"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	test?
	(
		dev-java/ant-junit:0
		dev-java/junit-addons:0
	)
	${COMMON_DEPEND}"

S="${WORKDIR}"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="stempel,commons-cli-1"

src_unpack() {
	unpack ${A}
	rm -rv lib/* doc || die
}

src_install() {
	java-pkg_newjar tmp/bin/${P}.jar ${PN}.jar
	java-pkg_newjar tmp/bin/${PN}-nodict-${PV}.jar ${PN}-nodict.jar
	use doc && java-pkg_dojavadoc tmp/javadoc
	use source && java-pkg_dosrc src/morfologik
	dodoc README.txt || die
}

src_test() {
	java-pkg_jar-from --into lib junit,junit-addons
	ANT_TASKS="ant-junit" eant test
}
