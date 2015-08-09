# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java Graph Editing Framework"
HOMEPAGE="http://gef.tigris.org"

MY_PN="GEF"
SRC_URI="http://${PN}.tigris.org/files/documents/9/43167/${MY_PN}-${PV}-src.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"

IUSE=""

COMMON_DEP="
	dev-java/commons-logging
	sci-libs/jmol-acme
	"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEP}"

S=${WORKDIR}/src

src_unpack() {
	mkdir src
	cd src
	unpack ${A}
	epatch "${FILESDIR}/0.12.3-javadoc.patch"
	rm -vr Acme || die
	java-ant_rewrite-classpath
}

EANT_GENTOO_CLASSPATH="commons-logging,jmol-acme"
EANT_BUILD_TARGET="package"
EANT_DOC_TARGET="prepare-docs"

src_install() {
	java-pkg_dojar ../lib/${PN}.jar
	use source && java-pkg_dosrc org
	use doc && java-pkg_dojavadoc ../docs
	dodoc README.txt
}
