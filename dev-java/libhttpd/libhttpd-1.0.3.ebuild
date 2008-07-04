# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source test"
inherit eutils java-pkg-2 versionator

MY_PV=$(delete_version_separator 2 )
MY_PV="${MY_PV}_2007-07-23"
DESCRIPTION="Blommers IT java HTTP Server Library"
HOMEPAGE="http://www.blommers-it.nl/libhttpd/"
SRC_URI="mirror://sourceforge/java-libhttpd/${PN}-src_v${MY_PV}.zip
	 doc? ( mirror://sourceforge/java-libhttpd/${PN}-doc_v${MY_PV}.zip )"

LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"

SLOT="0"

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	test? ( dev-java/junit )"

S="${WORKDIR}"

src_compile() {
	cd "${S}"/${PN}/src || die
	find . -name '*.java' -print > sources.list
	ejavac @sources.list
	find . -name '*.class' -print > classes.list
	touch myManifest
	jar cmf myManifest ${PN}.jar @classes.list
}

src_install() {
	java-pkg_dojar ${PN}/src/${PN}.jar
	dodoc ${PN}/src/com/blommersit/httpd/doc-files/*
	use doc && java-pkg_dojavadoc ${PN}-apidocs/
	use source && java-pkg_dosrc ${PN}/src/com
}

src_test() {
	cd "${S}"/${PN}/test || die
	find . -name '*.java' -print > sources.list
	local classpath=.:$(java-pkg_getjars --build-only junit):../src/${PN}.jar
	ejavac -cp ${classpath} @sources.list
	ejunit -cp ${classpath} com.blommersit.httpd.routes.TestRoutes
}
