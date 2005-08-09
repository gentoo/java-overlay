# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/mx4j/mx4j-2.1.0.ebuild,v 1.6 2005/06/09 01:07:08 mr_bones_ Exp $

inherit eutils java-pkg

DESCRIPTION="MX4J is a project to build an Open Source implementation of the Java(TM) Management Extensions (JMX) and of the JMX Remote API (JSR 160) specifications, and to build tools relating to JMX."
HOMEPAGE="http://mx4j.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.gz"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-1.6
	jikes? ( >=dev-java/jikes-1.21 )
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4
	>=dev-java/commons-logging-1.0.4
	>=dev-java/sun-jaf-bin-1.0.2
	>=dev-java/sun-javamail-bin-1.3.1
	>=dev-java/jython-2.1
	=dev-java/servletapi-2.3*
	=dev-java/xmlunit-1*
	=www-servers/axis-1*
	~www-servers/resin-3.0.8
	!>www-servers/resin-3.0.9"
	
# we really _shouldn't_ have to depend on resin... instead we're
# supposed to be able to use hessian and burlap
# but I can't figure out what version they want.
# resin provides the packages we need...
# but we need to block resin-3.0.12 because the mx4j doesn't like it
# TODO find version of hessian + burlap we should be using
LICENSE="mx4j"
SLOT="2.1"
KEYWORDS="x86 amd64"
IUSE="doc examples jikes source"

src_unpack(){
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/mx4j-2.1.0-gentoo.patch

	cd ${S}/lib
	java-pkg_jar-from sun-jaf-bin
	java-pkg_jar-from sun-javamail-bin mail.jar
	java-pkg_jar-from jython
	java-pkg_jar-from axis-1
	java-pkg_jar-from servletapi-2.3
	java-pkg_jar-from resin resin.jar
	java-pkg_jar-from xmlunit-1
	has_version =jetty-5* && java-pkg_jar-from jetty-5 org.mortbay.jetty.jar
}

src_compile() {
	local antflags="-f build/build.xml compile.jmx compile.rjmx compile.tools"
	use doc && antflags="${antflags} javadocs"
	use examples && antflags="${antflags} compile.examples"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "ant failed"
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

pkg_postinst() {
	einfo "To get jetty support, emerge =jetty-5*, then re-emerge mx4j"
}
