# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

JAVA_PKG_IUSE="source"

inherit java-pkg-2 java-ant-2 subversion

DESCRIPTION="A library for managing images based on JAI"
HOMEPAGE="https://jai-imageio.dev.java.net/"
SRC_URI=""
ESVN_REPO_URI="https://svn.java.net/svn/jai-imageio-core~svn/tags/jai-imageio-1_1-fcs"

LICENSE="jai-imageio sun-bcla-jclib4jai"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="
	dev-java/sun-jai-bin:0"
DEPEND="${CDEPEND}
	>=virtual/jdk-1.4"
RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

S="${WORKDIR}/${PN}-core"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="sun-jai-bin"
EANT_GENTOO_CLASSPATH_EXTRA="src/share/jclib4jai/clibwrapper_jiio.jar"

src_install() {
	dohtml www/index.html
	use source && java-pkg_dosrc src/share/classes/*

	cd build/*/opt/lib || die
	java-pkg_dojar ext/clibwrapper_jiio.jar ext/jai_imageio.jar
	java-pkg_doso */libclib_jiio.so
}
