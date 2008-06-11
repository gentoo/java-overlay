# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="A pure Java Subversion client library"
HOMEPAGE="http://svnkit.com/"
SRC_URI="http://www.svnkit.com/org.tmatesoft.svn_${PV}.src.zip"
KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="tmate"
IUSE=""

CDEPEND="=dev-util/subversion-1.4*
	dev-java/trilead-ssh2
	dev-java/sequence
	dev-java/jna"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.4"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

S="${WORKDIR}/${PN}-src-${PV}.4142"

EANT_BUILD_TARGET="build-library build-cli"
EANT_DOC_TARGET="build-doc"

pkg_setup() {
	java-pkg-2_pkg_setup
	if ! built_with_use dev-util/subversion java ; then
		msg="${CATEGORY}/${P} needs dev-util/subversion built with the java USE flag"
		error ${msg}
		die ${msg}
	fi
}

src_unpack() {
	unpack ${A}
	
	cd "${S}"
	epatch "${FILESDIR}/${P}-build.xml.patch"
	
	rm -r contrib/* || die
	java-pkg_jar-from --into contrib jna,trilead-ssh2,sequence,subversion
}

src_install() {
	cd build/lib
	java-pkg_dojar *.jar
	dodoc *.txt || die

	cd "${S}"
	use doc && java-pkg_dojavadoc build/doc/javadoc
	use source && java-pkg_dosrc svnkit/src/*
}
