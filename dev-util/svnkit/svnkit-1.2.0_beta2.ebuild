# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
JAVA_PKG_IUSE="doc source"
inherit eutils versionator java-pkg-2 java-ant-2

DESCRIPTION="A pure Java Subversion client library"
HOMEPAGE="http://svnkit.com/"
SRC_URI="http://www.svnkit.com/org.tmatesoft.svn_`replace_version_separator 3 -`.src.zip"
KEYWORDS="~amd64"
SLOT="1.2"
LICENSE="tmate"
IUSE=""

CDEPEND="=dev-util/subversion-1.5*
	dev-java/trilead-ssh2
	dev-java/sequence:1.2
	dev-java/jna"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.4"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

S="${WORKDIR}/${PN}-src-`get_version_component_range 1-3`.4471"

EANT_BUILD_TARGET="build-library build-cli"
EANT_DOC_TARGET="build-doc"

pkg_setup() {
	java-pkg-2_pkg_setup
	if ! built_with_use =dev-util/subversion-1.5* java ; then
		msg="${CATEGORY}/${P} needs dev-util/subversion built with the java USE flag"
		eerror ${msg}
		die ${msg}
	fi
}

src_unpack() {
	unpack ${A}

	cd "${S}" || die
	epatch "${FILESDIR}/${P}-build.xml.patch"

	rm -r contrib/* || die
	java-pkg_jar-from --into contrib jna,trilead-ssh2,sequence:1.2,subversion
}

src_install() {
	cd build/lib || die
	java-pkg_dojar *.jar
	dodoc *.txt || die

	cd "${S}" || die
	use doc && java-pkg_dojavadoc build/doc/javadoc
	use source && java-pkg_dosrc svnkit/src/*
}
