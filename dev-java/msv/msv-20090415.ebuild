# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

EAPI="2"
inherit eutils java-pkg-2 java-pkg-simple

DESCRIPTION="Multi-Schema XML Validator, a Java tool for validating XML documents"
HOMEPAGE="http://www.sun.com/software/xml/developers/multischema/ https://msv.dev.java.net/"
SRC_URI="http://java.net/downloads/${PN}/releases/${P//-/.}.zip"

LICENSE="BSD Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/iso-relax:0
	dev-java/relaxng-datatype:0
	dev-java/xml-commons-resolver:0
	dev-java/xsdlib:0"

RDEPEND="${CDEPEND}
	dev-java/xerces:2
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.5"

S="${WORKDIR}/${P}"

JAVA_SRC_DIR="src"
JAVA_GENTOO_CLASSPATH="iso-relax relaxng-datatype xml-commons-resolver xsdlib"

src_compile() {
	java-pkg-simple_src_compile
	cd "${JAVA_SRC_DIR}" || die
	jar uf "${S}/${PN}.jar" $(find -name "*.properties") || die
}

src_install() {
	java-pkg-simple_src_install
	java-pkg_register-dependency xerces-2
	java-pkg_dolauncher "${PN}" --main com.sun.msv.driver.textui.Driver
	dodoc README.txt ChangeLog.txt || die
}
