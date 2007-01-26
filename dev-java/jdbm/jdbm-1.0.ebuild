# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jdbm/jdbm-0.12-r1.ebuild,v 1.1 2006/12/21 12:42:06 betelgeuse Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Jdbm aims to be for Java what GDBM is for Perl, Python, C, ..."
HOMEPAGE="http://jdbm.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.zip"

LICENSE="BSD"
SLOT="1"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.4"

DEPEND="
	>=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip
	test? ( dev-java/ant-junit dev-java/ant-trax )"

src_unpack() {
	unpack ${A}
	cd "${S}/lib"
	rm -v *.jar || die
}

src_compile() {
	cd "${S}/src"
	java-pkg-2_src_compile -Dversion="${PV}"
}

src_test() {
	cd "${S}/src"
	ANT_TASKS="ant-trax" eant tests.run \
		-Dclasspath="$(java-pkg_getjars junit):./build/classes"
}

src_install() {
	java-pkg_newjar dist/${P}.jar
	use doc && java-pkg_dojavadoc build/doc/javadoc
	use source && java-pkg_dosrc src/main/*
}
