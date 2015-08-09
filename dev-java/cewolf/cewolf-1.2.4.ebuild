# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Cewolf is a tag library for charts of all kinds. It enables every JSP to easily embedd chart images."
HOMEPAGE="http://cewolf.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

COMMON_DEPEND="
	>=dev-java/jfreechart-1.0.14:1.0
	>=dev-java/jcommon-1.0.18:1.0
	dev-java/batik:1.8
	dev-java/commons-logging:0
	java-virtuals/servlet-api:2.5
"
DEPEND="${COMMON_DEPEND}
	app-arch/unzip
	>=dev-java/ant-core-1.6
	>=virtual/jdk-1.5
	source? ( app-arch/zip )
"
RDEPEND="${COMMON_DEPEND}
	>=virtual/jre-1.5
	>=dev-java/log4j-1.2.12
"

JAVA_GENTOO_CLASSPATH="batik-1.8,commons-logging,jcommon-1.0,jfreechart-1.0,servlet-api-2.5"
JAVA_SRC_DIR="src/main/java"

S="${WORKDIR}/${P}"

src_install() {
	java-pkg-simple_src_install
	dodoc LICENSE.txt
	use doc && java-pkg_dohtml -r javadoc tagdoc
	use source && java-pkg_dosrc src/main/java/de
}
