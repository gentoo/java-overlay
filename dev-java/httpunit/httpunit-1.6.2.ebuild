# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="HttpUnit emulates the relevant portions of browser behavior."
HOMEPAGE="http://httpunit.sourceforge.net/"
# TODO what is metainf for?
# TODO where did it come from?
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=">=virtual/jre-1.4
	=dev-java/junit-3.8*"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	=dev-java/junit-3.8*"

src_unpack() {
	unpack ${A}
	find ${S} -name "*.jar" | xargs rm -v

	cd ${S}/jars
	java-pkg_jar-from junit
}

src_compile() {
	java-pkg_filter-compiler jikes
	eant clean jar $(use_doc javadocs)
}

src_install() {
	java-pkg_dojar lib/${PN}.jar
	dodoc doc/*.txt
	if use doc; then
		dohtml doc/manual doc/tutorial
		java-pkg_dojavadoc doc/api
	fi
}
