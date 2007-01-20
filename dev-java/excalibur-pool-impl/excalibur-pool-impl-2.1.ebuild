# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/excalibur-logger/excalibur-logger-2.1.ebuild,v 1.2 2006/12/22 18:12:09 betelgeuse Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Pool from the Excalibur containerkit"
HOMEPAGE="http://excalibur.apache.org/component-list.html"
SRC_URI="mirror://apache/excalibur/${PN/-impl}/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source"

RDEPEND=">=virtual/jre-1.4"

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		source? ( app-arch/zip )
		test? ( 
			dev-java/junit 
			dev-java/junitperf
			dev-java/ant-tasks 
		)"

S=${WORKDIR}/${PN}


src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/2.1-build.xml-javadoc.patch"

	java-ant_ignore-system-classes
	mkdir -p target/lib
	cd target/lib || die
	java-pkg_jar-from avalon-framework-4.2
	java-pkg_jar-from commons-collections
	java-pkg_jar-from concurrent-util
	java-pkg_jar-from excalibur-pool-api
}

src_test() {
	cd target/lib
	java-pkg_jar-from --build-only junit
	java-pkg_jar-from --build-only junitperf
	cd "${S}"
	eant test -DJunit.present=true
}

src_install() {
	java-pkg_newjar target/${P}.jar
	dodoc NOTICE.txt
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
