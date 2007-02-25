# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A high-level Java API for Subversion"
HOMEPAGE="http://subclipse.tigris.org/svnClientAdapter.html"
SRC_URI="http://subclipse.tigris.org/files/documents/906/36427/subclipse-source_1.2.0.zip"
KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="Apache-1.1"

IUSE="test"

COMMON_DEPEND="
	dev-java/ganymed-ssh2
	>=dev-util/subversion-1.4
	dev-util/svnkit"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant
	source? ( app-arch/zip )
	test? (
		=dev-java/junit-3.8*
		dev-java/sequence
	)
	${COMMON_DEPEND}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"

S="${WORKDIR}/svnClientAdapter"

EANT_BUILD_TARGET="svnClientAdapter.jar"
EANT_DOC_TARGET="javadoc"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-build.xml.patch

	mkdir lib
	cd lib
	java-pkg_jar-from ganymed-ssh2 ganymed-ssh2.jar ganymed.jar
	java-pkg_jar-from svnkit svnkit.jar
	java-pkg_jar-from subversion svn-javahl.jar svnjavahl.jar
}

src_test() {
	eant runTests -Djunit.jar=$(java-pkg_getjars junit) -Dsequence.jar=$(java-pkg_getjars sequence)
}

src_install() {
	java-pkg_dojar build/lib/svnClientAdapter.jar
	use doc && java-pkg_dojavadoc build/javadoc
	use source && java-pkg_dosrc src
	dodoc changelog.txt readme.txt
}
