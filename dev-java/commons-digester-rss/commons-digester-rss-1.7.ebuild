# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-digester/commons-digester-1.7-r2.ebuild,v 1.2 2006/10/05 15:22:54 gustavoz Exp $

inherit eutils java-pkg-2 java-ant-2

MY_PN="commons-digester"
MY_P="${MY_PN}-${PV}-src"
DESCRIPTION="An rss library application from the commons-digester examples."
HOMEPAGE="http://jakarta.apache.org/commons/digester/"
SRC_URI="mirror://apache/jakarta/commons/digester/source/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="doc source"

# 1.3 support might be possible by adding an additional depend on 
# xml-commons[-external, but 1.3 is gone anyway
RDEPEND=">=virtual/jre-1.4
	=dev-java/commons-beanutils-1.6*
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-logging-1.0.2
	>=dev-java/commons-digester-1.7"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.4
        source? ( app-arch/zip )
	${RDEPEND}"

S="${WORKDIR}/${MY_P}/src/examples/rss"

# don't rewrite build.xml in examples 
# JAVA_PKG_BSFIX_ALL="no"

src_unpack() {
	unpack ${A}
	cd ${S}

	# this build.xml honours build.properties so we use it for common depends
	# needed for both compile and test, so getjar is called only once
	echo "commons-beanutils.jar=$(java-pkg_getjar commons-beanutils-1.6 \
		 commons-beanutils.jar)" > build.properties
	echo "commons-collections.jar=$(java-pkg_getjar commons-collections \
		commons-collections.jar)" >> build.properties
	echo "commons-logging.jar=$(java-pkg_getjar commons-logging \
		commons-logging.jar)" >> build.properties
	echo "commons-digester.jar=$(java-pkg_getjar commons-digester \
		commons-digester.jar)" >> build.properties

	sed -i "s/compile,javadoc/compile/" build.xml \
		|| die "Failed patch rss build.xml"
}

src_compile() {
	eant dist $(use_doc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	dodoc readme.txt LICENSE.txt

	use doc && java-pkg_dohtml -r dist/docs/api
	use source && java-pkg_dosrc src/java/org
}
