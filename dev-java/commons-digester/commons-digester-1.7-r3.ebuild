# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-digester/commons-digester-1.7-r2.ebuild,v 1.2 2006/10/05 15:22:54 gustavoz Exp $

inherit eutils java-pkg-2 java-ant-2

MY_P="${P}-src"
DESCRIPTION="Reads XML configuration files to provide initialization of various Java objects within the system."
HOMEPAGE="http://jakarta.apache.org/commons/digester/"
SRC_URI="mirror://apache/jakarta/commons/digester/source/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="doc examples source test"

# 1.3 support might be possible by adding an additional depend on 
# xml-commons[-external, but 1.3 is gone anyway
RDEPEND=">=virtual/jre-1.4
	=dev-java/commons-beanutils-1.6*
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-logging-1.0.2"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.4
	test? ( >=dev-java/junit-3.7 )
	source? ( app-arch/zip )
	${RDEPEND}"

S="${WORKDIR}/${P}-src"

# don't rewrite build.xml in examples 
# JAVA_PKG_BSFIX_ALL="no"

src_unpack() {
	unpack ${A}
	cd  "${S}"
	epatch "${FILESDIR}/${PV}-build.xml-jar-target.patch"

	# this build.xml honours build.properties so we use it for common depends
	# needed for both compile and test, so getjar is called only once
	echo "commons-beanutils.jar=$(java-pkg_getjar commons-beanutils-1.6 \
		 commons-beanutils.jar)" > build.properties
	echo "commons-collections.jar=$(java-pkg_getjar commons-collections \
		commons-collections.jar)" >> build.properties
	echo "commons-logging.jar=$(java-pkg_getjar commons-logging \
		commons-logging.jar)" >> build.properties

	sed -i "s/compile,javadoc/compile/" "src/examples/rss/build.xml" \
		|| die "Failed patch rss build.xml"
}

src_compile() {
	eant jar $(use_doc)

	cd src/examples/rss
	eant -Dcommons-digester.jar=../../../dist/${PN}.jar dist
}

src_test() {
	eant -Djunit.jar="$(java-pkg_getjar --build-only junit junit.jar)" test
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	java-pkg_dojar src/examples/rss/dist/${PN}-rss.jar

	dodoc NOTICE.txt RELEASE-NOTES.txt

	use doc && java-pkg_dohtml -r dist/docs/api
	use source && java-pkg_dosrc src/java/org
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r src/examples/* ${D}/usr/share/doc/${PF}/examples
	fi
}
