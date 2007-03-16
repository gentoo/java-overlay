# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="StatSVN is a metrics-analysis tool for charting software evolution through analysis of Subversion source repositories."
HOMEPAGE="http://www.statsvn.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source test"

COMMON_DEPEND="
	>=dev-util/statcvs-0.3
	>=dev-java/backport-util-concurrent-3.0
	>=dev-java/jcommon-1.0
	>=dev-java/jfreechart-1.0"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/zip
	test? ( =dev-java/junit-3.8* )
	${COMMON_DEPEND}"

RDEPEND=">=virtual/jre-1.4
	>=dev-util/subversion-1.3.0
	${COMMON_DEPEND}"

src_unpack() {
	unpack ${A}

	# patches tests so they do not attempt to create cache in /root/.statsvn
	#cd ${S}/tests-src/net/sf/statsvn/input
	cd ${S}
	epatch ${FILESDIR}/${P}-build.xml.patch
	java-ant_rewrite-classpath

	rm ${S}/lib/*.jar
}

src_compile() {
	eant -Dgentoo.classpath=$(java-pkg_getjars statcvs,backport-util-concurrent,jcommon-1.0,jfreechart-1.0) dist $(use_doc)
}

src_test() {
	ewarn "Note that the tests require you to be online."
	java-pkg_jar-from --into lib junit
	eant -Dgentoo.classpath=$(java-pkg_getjars statcvs,backport-util-concurrent,jcommon-1.0,jfreechart-1.0) test
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	# jfreechart pulls in gnu-jaxp which doesn't work for statsvn so we need
	# to force another SAXParserFactory and DocumentBuilderFactory
	java-pkg_dolauncher statsvn --main net.sf.statsvn.Main \
		--java_args '-Djavax.xml.parsers.SAXParserFactory=com.sun.org.apache.xerces.internal.jaxp.SAXParserFactoryImpl -Djavax.xml.parsers.DocumentBuilderFactory=com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl'

	use doc && java-pkg_dojavadoc doc
	use source && java-pkg_dosrc src/*
}

pkg_postinst() {
	elog "For instractions on how to use StatSVN see"
	elog "http://svn.statsvn.org/statsvnwiki/index.php/Main_Page"
}
