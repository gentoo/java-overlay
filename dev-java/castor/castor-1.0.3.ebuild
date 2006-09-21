# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Data binding framework for Java"
HOMEPAGE="http://www.castor.org"
SRC_URI="http://dev.gentoo.org/~nichoj/distfiles/${P}.tar.bz2"
# svn co https://svn.codehaus.org/castor/castor/tags/1.0.3/ castor-1.0.3
# cd castor-1.0.3
# mvn ant:ant
# do some magic to build.xml
# rm lib/*
# cd ../
# tar cjvf castor-1.0.3.tar.bz2 --exclude=.svn castor-1.0.3

LICENSE="Exolab"
SLOT="1.0"
KEYWORDS="~amd64"
IUSE="doc source"

COMMON_DEPS="=dev-java/adaptx-0.9*
	=dev-java/cglib-2.0*
	dev-java/commons-logging
	=dev-java/jakarta-oro-2.0*
	=dev-java/jakarta-regexp-1.3*
	dev-java/jta
	=dev-java/ldapsdk-4.1*
	dev-java/log4j
	~dev-java/servletapi-2.4
	dev-java/ant-core
	dev-java/junit"
# Does not like Java 1.6's JDBC API
DEPEND="|| (
		=virtual/jdk-1.4*
		=virtual/jdk-1.5*
	)
	source? ( app-arch/zip )
	${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPS}"

src_unpack() {
	unpack ${A}
	cd ${S}/lib
	java-pkg_jar-from adaptx-0.9
	java-pkg_jar-from cglib-2 cglib.jar
	java-pkg_jar-from commons-logging commons-logging-api.jar
	java-pkg_jar-from jakarta-oro-2.0
	java-pkg_jar-from jakarta-regexp-1.3
	java-pkg_jar-from jta
	java-pkg_jar-from ldapsdk-4.1 ldapjdk.jar
	java-pkg_jar-from log4j
	java-pkg_jar-from servletapi-2.4 servlet-api.jar
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from junit
}

src_compile() {
	cd ${S}/src/
	eant clean jar $(use_doc)
}

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar
	java-pkg_newjar dist/${P}-commons.jar ${PN}-commons.jar
	java-pkg_newjar dist/${P}-xml.jar ${PN}-xml.jar
	use source && java-pkg_dosrc src/main/*/org
	use doc && java-pkg_dojavadoc build/doc/javadoc
}
