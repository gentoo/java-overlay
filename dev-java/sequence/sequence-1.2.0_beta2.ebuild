# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"
inherit eutils versionator java-pkg-2 java-ant-2

DESCRIPTION="Helper library for SVNKit"
HOMEPAGE="http://svnkit.com/"
SRC_URI="http://www.svnkit.com/org.tmatesoft.svn_`replace_version_separator 3 -`.src.zip"
KEYWORDS="~amd64"
SLOT="1.2"
LICENSE="sequence"
IUSE="test"

DEPEND=">=virtual/jdk-1.4
	test? ( dev-java/ant-junit )"

RDEPEND=">=virtual/jre-1.4"

MY_PV=`get_version_component_range 1-3`
S="${WORKDIR}/svnkit-src-${MY_PV}.4471/contrib/sequence"

EANT_BUILD_TARGET="jar"
EANT_DOC_TARGET="javadoc"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	cp "${FILESDIR}/${PN}-${MY_PV}-build.xml" build.xml || die
	mkdir -p lib || die
}

src_install() {
	java-pkg_newjar "dist/${PN}-${MY_PV}.jar" "${PN}.jar"

	use doc && java-pkg_dojavadoc dist/javadoc
	use source && java-pkg_dosrc src/*
}

src_test() {
	java-pkg_jar-from --into lib junit
	ANT_TASKS="ant-junit" eant test
}
