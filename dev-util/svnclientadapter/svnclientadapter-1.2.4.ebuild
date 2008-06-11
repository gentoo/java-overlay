# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"
WANT_ANT_TASKS="ant-junit ant-nodeps"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A high-level Java API for Subversion"
HOMEPAGE="http://subclipse.tigris.org/svnClientAdapter.html"
SRC_URI="http://subclipse.tigris.org/files/documents/906/39521/subclipse-source_${PV}.zip"
KEYWORDS="~amd64"
SLOT="0"
LICENSE="Apache-2.0"
IUSE="test"

CDEPEND="=dev-util/subversion-1.4*
	dev-util/svnkit"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.4
	test? ( dev-java/sequence )"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

S="${WORKDIR}/svnClientAdapter"

EANT_BUILD_TARGET="svnClientAdapter.jar"
EANT_DOC_TARGET="javadoc"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-build.xml.patch"

	mkdir -p lib || die
	java-pkg_jar-from --into lib --with-dependencies svnkit,subversion
	ln -snf svn-javahl.jar lib/svnjavahl.jar
}

src_install() {
	java-pkg_dojar build/lib/svnClientAdapter.jar
	use doc && java-pkg_dojavadoc build/javadoc
	use source && java-pkg_dosrc src
	dodoc changelog.txt readme.txt
}

src_test() {
	EANT_GENTOO_CLASSPATH="sequence" eant runTests
}
