# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/struts-legacy/struts-legacy-1.0-r2.ebuild,v 1.1 2007/04/29 00:01:43 caster Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Jakarta Struts Legacy Library"
SRC_URI="mirror://apache/jakarta/struts/struts-legacy/${P}-src.tar.gz"
HOMEPAGE="http://jakarta.apache.org/struts/"
IUSE="doc"
COMMON_DEP="dev-java/commons-logging"
RDEPEND=">=virtual/jre-1.4
		${COMMON_DEP}"
# 1.6 adds some abstract method somewhere that this doesn't override
DEPEND="|| ( =virtual/jdk-1.5* =virtual/jdk-1.4* )
		${COMMON_DEP}"
LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

S=${WORKDIR}/${P}-src

src_compile() {
	sed -i 's:compile,docs:compile:' build.xml || die "sed failed"
	echo "commons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)" > build.properties
	echo "jdk.version=1.4" >> build.properties

	eant dist $(use_doc docs)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	newdoc STATUS.txt STATUS
	use doc && java-pkg_dojavadoc dist/docs/api
}
