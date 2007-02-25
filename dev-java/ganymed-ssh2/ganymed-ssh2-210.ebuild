# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

S="${WORKDIR}/ganymed-ssh2-build${PV}"

DESCRIPTION="A library that implements the SSH2 protocol in pure Java"
HOMEPAGE="http://www.ganymed.ethz.ch/ssh2/"
SRC_URI="http://www.ganymed.ethz.ch/ssh2/ganymed-ssh2-build${PV}.zip"
KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="ganymed-ssh2"
IUSE="examples"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant
	source? ( app-arch/zip )"

RDEPEND=">=virtual/jre-1.4"

EANT_BUILD_TARGET="ganymed-ssh2.jar"
EANT_DOC_TARGET="javadoc"

src_unpack() {
	unpack "${A}"
	find -name "*.jar" -delete

	# ganymed does not provide its own build files so we took the ones from here:
	# http://debian-eclipse.wfrag.org/tracpy/browser/ganymed-ssh2/trunk
	cp ${FILESDIR}/${P}-debian-build.xml ${S}/build.xml || die "Cannot copy build.xml"
	cp ${FILESDIR}/${P}-debian-build.properties ${S}/build.properties || die "Cannot copy build.properties"
}

src_install() {
	java-pkg_dojar build/lib/ganymed-ssh2.jar

	dodoc HISTORY.txt README.txt
	dohtml faq/FAQ.html
	use doc && java-pkg_dojavadoc javadoc

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi

	use source && java-pkg_dosrc src
}
