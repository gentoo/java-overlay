# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="P6Spy is a framework that enables database data to be seamlessly intercepted and manipulated with no code changes to existing application"
HOMEPAGE="http://www.p6spy.com/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src.zip"

LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	jikes? ( dev-java/jikes )"
RDEPEND=">=virtual/jre-1.4
	=dev-java/jboss-module-jmx-4.0*
	=dev-java/jboss-module-system-4.0*
	=dev-java/jboss-module-common-4.0*
	=dev-java/gnu-regexp-1*
	>=dev-java/jakarta-regexp-1.3-r2
	=dev-java/jakarta-regexp-1*
	dev-java/ant-core
	dev-java/log4j"
# TODO fix for Java 1.6... has problems due to JDBC4
JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4* =virtual/jdk-1.5*"

S=${WORKDIR}

ant_src_unpack() {
	unpack ${A}
	
	# fixes the names of some jboss packages referenced
	epatch ${FILESDIR}/${P}-gentoo.patch

	mkdir lib
	cd lib
	java-pkg_jar-from jboss-module-jmx-4 jboss-jmx.jar
	java-pkg_jar-from jboss-module-system-4 jboss-system.jar
	java-pkg_jar-from jboss-module-common-4 jboss-common.jar
	java-pkg_jar-from gnu-regexp-1
	java-pkg_jar-from log4j
	java-pkg_jar-from jakarta-regexp-1.3
	java-pkg_jar-from ant-core ant.jar
}

src_compile() {
	eant clean jar $(use_doc docs -Djavadocs=dist/api) 
}

src_install() {
	java-pkg_dojar dist/*.jar
	dodoc features.txt
	use doc && java-pkg_dojavadoc dist/api
}
