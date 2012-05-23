# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-pkg-simple

DESCRIPTION="A Java tool to validate XML documents against several kinds of XML schemata"
HOMEPAGE="https://msv.dev.java.net/"
SRC_URI="http://java.net/downloads/msv/releases/${P//-/.}.zip"

LICENSE="as-is Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/relaxng-datatype:0
	dev-java/xerces:2"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.4"

S="${WORKDIR}/${P}"

JAVA_SRC_DIR="src src-apache"
JAVA_GENTOO_CLASSPATH="relaxng-datatype xerces-2"

src_prepare() {
	rm -v *.jar || die
}

src_compile() {
	java-pkg-simple_src_compile

	local DIR; for DIR in ${JAVA_SRC_DIR}; do
		cd "${S}/${DIR}" || die
		jar uf "${S}/${PN}.jar" $(find -name "*.properties") || die
	done
}

src_install() {
	java-pkg-simple_src_install
	dodoc README.txt || die
	dohtml HowToUse.html || die
}
