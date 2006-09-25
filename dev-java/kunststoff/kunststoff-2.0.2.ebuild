# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator

MY_PV=$(replace_all_version_separators _)
DESCRIPTION="An extension to the the Java Metal Look&Feel"
HOMEPAGE="http://www.incors.org/archive/index.php3"
SRC_URI="http://www.incors.org/archive/kunststoff-2_0_2.zip"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="-*"
IUSE=""

DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cp ${FILESDIR}/build.xml ./build.xml
	#eant clean
}

src_compile() {
	eant dist
}

src_install() {
	java-pkg_dojar dist/*.jar
}
