# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Another PostgreSQL Diff Tool is a simple PostgreSQL diff tool that is useful for schema upgrades."
HOMEPAGE="http://apgdiff.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.zip"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source test"

DEPEND=">=virtual/jdk-1.5
	>=dev-java/ant-core-1.7.0
	>=dev-java/ant-junit-1.7.0
	app-arch/zip
	test? ( >=dev-java/junit-4.1 )"

RDEPEND=">=virtual/jre-1.5"

src_unpack() {
	unpack ${A}

	mkdir ${S}/lib
	cd ${S}/lib
	use test && java-pkg_jar-from --build-only junit-4
}

src_compile() {
	eant -Dnoget=true jar $(use_doc)
}

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar
	java-pkg_dolauncher apgdiff --jar ${PN}.jar

	use doc && java-pkg_dohtml -r dist/javadoc/*
	use source && java-pkg_dosrc src/main/java/*
}

src_test() {
	ANT_TASKS="ant-junit" eant -Dnoget=true test
}
