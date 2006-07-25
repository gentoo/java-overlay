# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="MX4J is a project to build an Open Source implementation of the Java(TM) Management Extensions (JMX) and of the JMX Remote API (JSR 160) specifications, and to build tools relating to JMX."
HOMEPAGE="http://mx4j.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.gz"
DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.6
	jikes? ( >=dev-java/jikes-1.21 )
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.3
	dev-java/bcel
	dev-java/commons-logging
	dev-java/log4j
	=www-servers/axis-1*
	~dev-java/servletapi-2.3
	=dev-java/gnu-jaf-1*
	=dev-java/gnu-javamail-1*
	dev-java/jython
	=dev-java/hessian-3.0.8*
	=dev-java/burlap-3.0*
"
	
LICENSE="mx4j"
SLOT="3.0"
KEYWORDS="x86 amd64"
IUSE="doc examples source"

src_unpack() {
	unpack ${A}

	cd ${S}/lib
	java-pkg_jar-from bcel
	java-pkg_jar-from commons-logging commons-logging.jar
	java-pkg_jar-from log4j
	java-pkg_jar-from axis-1
	java-pkg_jar-from servletapi-2.3
	java-pkg_jar-from gnu-jaf-1
	java-pkg_jar-from gnu-javamail-1 gnumail.jar mail.jar
	java-pkg_jar-from jython
	java-pkg_jar-from hessian-3.0.8
	java-pkg_jar-from burlap-3.0
}

src_compile() {
	eant -f build/build.xml \
		compile.jmx compile.rjmx compile.tools \
		$(use_doc javadocs) $(use examples && echo compile.examples)
}

src_install () {
	java-pkg_dojar dist/lib/*.jar
	java-pkg_dowar dist/lib/*.war

	dodoc LICENSE README
	use doc &&	java_pkg-dohtml -r dist/docs/api/*

	use source && java-pkg_dosrc ${S}/src/core/*

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r src/examples/mx4j/examples/* ${D}usr/share/doc/${PF}/examples
	fi
}
