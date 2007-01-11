# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A junit module, allowing to test private and protected Java classes, methods and variables."
HOMEPAGE="http://www.extreme-java.de/junitx/"
SRC_URI="http://www.extreme-java.de/dist/${P}-src.jar"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source"

COMMON_DEP="dev-java/junit"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		source? ( app-arch/zip )
		${COMMON_DEP}"

S="${WORKDIR}"

src_compile() {
	local cp="-classpath $(java-pkg_getjars junit)"
	ejavac */*/*.java ${cp}
	jar cf ${PN}.jar ${PN} || die
	if use doc; then
		javadoc */*/*.java -d api ${cp} || die
	fi
}

src_install() {
	java-pkg_dojar ${PN}.jar
	use source && java-pkg_dosrc ${PN}
	use doc && java-pkg_dojavadoc api
}
