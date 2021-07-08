# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
JAVA_PKG_IUSE="doc examples source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="${P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/xerces:2
	>=dev-java/log4j-1.2.8"

RDEPEND=">=virtual/jre-1.7
	${CDEPEND}"

DEPEND=">=virtual/jdk-1.7
		app-arch/unzip
		${CDEPEND}"

S=${WORKDIR}/${P}-src

src_unpack() {
	unpack ${A}

	cd "${S}/lib"
	rm -v *.jar || die

	java-pkg_jar-from xerces-2
	java-pkg_jar-from log4j log4j.jar log4j-1.2.8.jar
}

src_install() {
	java-pkg_newjar target/${P}-dev.jar ${PN}.jar

	use doc && java-pkg_dojavadoc dist/api
	use source && java-pkg_dosrc src/java/org
	use examples && java-pkg_doexamples src/java/examples
}
