# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=1

JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Algorithmic Stemmer for Polish Language"
HOMEPAGE="http://www.getopt.org/stempel/"
SRC_URI="http://www.getopt.org/${PN}/${PN}-src-${PV}.tgz"
LICENSE="Apache-2.0 Egothor"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4
	dev-java/lucene:1"
DEPEND=">=virtual/jdk-1.4
	dev-java/lucene:1"

S="${WORKDIR}"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="lucene-1"

src_unpack() {
	unpack ${A}
	rm -rv lib/* || die
}

src_install() {
	java-pkg_newjar build/${P}.jar ${PN}.jar
	use doc && java-pkg_dojavadoc build/api
	use source && java-pkg_dosrc src/org
	java-pkg_dohtml README.html
}
