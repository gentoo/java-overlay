# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# This can be used as a stand-alone application and as a servlet but it is
# currently only being installed as a library because its path handling
# when contained in a JAR is horribly broken and I don't have the patience
# to fix it right now. -- Chewi

EAPI="1"
JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

DESCRIPTION="The official CSS validator from W3C"
HOMEPAGE="http://jigsaw.w3.org/css-validator/"
SRC_URI="http://dev.gentooexperimental.org/~chewi/distfiles/${P}.tar.lzma"
LICENSE="W3C"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/commons-lang:2.1
	dev-java/servletapi:2.4
	dev-java/xerces:2
	dev-java/tagsoup
	dev-java/velocity
	www-servers/jigsaw"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="commons-lang-2.1 servletapi-2.4 xerces-2 tagsoup velocity jigsaw"

src_install() {
	java-pkg_dojar ${PN}.jar
#	java-pkg_dolauncher
	use source && java-pkg_dosrc org

	if use doc ; then
		dodoc docs/* || die
		java-pkg_dojavadoc javadoc
	fi
}

src_test() {
	local xml CP=".:${PN}.jar:"`java-pkg_getjars --with-dependencies "${EANT_GENTOO_CLASSPATH// /,}"`
	ejavac -cp "${CP}" autotest/*.java || die "tests failed to compile"

	for xml in autotest/testsuite/xml/*.xml ; do
		`java-config -J` -cp "${CP}" autotest.AutoTest "${xml}" || die "tests failed"
	done
}
