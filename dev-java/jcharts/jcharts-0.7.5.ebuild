# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_P="jCharts-${PV}"
DESCRIPTION="jCharts is a 100% Java based charting utility that outputs a variety of charts"
HOMEPAGE="http://jcharts.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc examples source"

COMMON_DEP="
	=dev-java/batik-1.6*
	=dev-java/servletapi-2.4*"

RDEPEND=">=virtual/jre-1.4
		${COMMON_DEP}"

DEPEND=">=virtual/jdk-1.4
		${COMMON_DEP}
		dev-java/ant-core
		app-arch/unzip
		source? ( app-arch/zip )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -v *.{jar,war} lib/*.jar
}

src_compile() {
	cd build
	local servletcp="$(java-pkg_getjars servletapi-2.4)"
	# zip file includes javadocs and 1.6 fails to generate them so we just use
	# the bundled ones
	eant jar \
		-Dbatik.classpath="$(java-pkg_getjars batik-1.6):${servletcp}"
}

src_install() {
	java-pkg_newjar build/*.jar
	dohtml docs/*.html
	use doc && java-pkg_dojavadoc javadocs
	use source && java-pkg_dosrc src/org
	if use examples; then
		dodir  /usr/share/doc/${PF}/examples
		insinto  /usr/share/doc/${PF}/examples
		doins -r demo/*
	fi
}
