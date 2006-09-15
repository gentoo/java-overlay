# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="TestNG is a testing framework inspired from JUnit and NUnit"
HOMEPAGE="http://testng.org/"
SRC_URI="http://testng.org/${P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5
		dev-java/ant
		app-arch/unzip
		source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.5"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd ${S}

	java-pkg_jar-from ant-core ant.jar 3rdparty/ant.jar
}

src_compile() {
	eant dist-15 $(use_doc javadocs)
}

src_install() {
	java-pkg_newjar ${P}-jdk15.jar ${PN}.jar

	use doc && java-pkg_dojavadoc javadocs/
	use source && java-pkg_dosrc src/jdk15/org/testng/
}
