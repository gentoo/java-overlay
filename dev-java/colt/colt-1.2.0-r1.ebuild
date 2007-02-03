# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/colt/colt-1.2.0.ebuild,v 1.3 2006/10/05 15:17:03 gustavoz Exp $

JAVA_PKG_IUSE="source doc"
WANT_ANT_TASKS="ant-core"

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="Colt provides a set of Open Source Libraries for High Performance Scientific and Technical Computing in Java."
SRC_URI="http://dsd.lbl.gov/~hoschek/colt-download/releases/${P}.zip"
HOMEPAGE="http://www-itg.lbl.gov/~hoschek/colt/"
LICENSE="colt"
IUSE=""
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

DEPEND=">=virtual/jdk-1.4
		>=dev-java/concurrent-util-1.3.4
		>=dev-java/ant-core-1.7
		app-arch/unzip"
RDEPEND=">=virtual/jre-1.4
		 >=dev-java/concurrent-util-1.3.4"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack "${A}"
	cd "${S}"

	epatch "${FILESDIR}/${P}-benchmark-no-deprecation.patch"

	find "${S}" -iname '*.jar' -exec rm \{\} \;

	cd "${S}/lib"
	java-pkg_jar-from concurrent-util
}

EANT_BUILD_TARGET="javac jar"

src_install() {
	java-pkg_dojar lib/${PN}.jar

	dohtml README.html
	use doc && java-pkg_dojavadoc doc/api
}
