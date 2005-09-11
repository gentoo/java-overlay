# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/castor/castor-0.9.5.3-r1.ebuild,v 1.2 2005/07/12 23:33:29 axxo Exp $

inherit eutils java-pkg

DESCRIPTION="Data binding framework for Java"
SRC_URI="http://dist.codehaus.org/${PN}/${PV}/${P}-src.tgz"
HOMEPAGE="http://www.castor.org"
LICENSE="Exolab"
KEYWORDS="~x86"
SLOT="0.9"
IUSE="doc jikes postgres source"

RDEPEND=">=virtual/jre-1.4
	>=dev-java/adaptx-0.9.5.3
	>=dev-java/commons-logging-1.0.4
	=dev-java/jakarta-oro-2.0*
	=dev-java/jakarta-regexp-1.3*
	>=dev-java/jta-1.0.1
	>=dev-java/ldapsdk-4.1.7
	>=dev-java/junit-3.8
	>=dev-java/log4j-1.2.8
	=dev-java/servletapi-2.3*
	=dev-java/xerces-1.3*
	=dev-java/cglib-2.0*
	postgres? ( =dev-java/jdbc2-postgresql-7.3* )"

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.5
	${RDEPEND}"

src_unpack() {
	unpack ${A}

	cd ${S}
	# TODO this should be filed upstream
	epatch ${FILESDIR}/0.9.5.3-jikes.patch

#	cd ${S}/src
	# Didn't axxo have some magic to do this for us? (add javac source and
	# target attributes)
	#epatch ${FILESDIR}/build-xml.patch

	cd ${S}/lib
	rm -f *.jar
	java-pkg_jar-from adaptx-0.9
	java-pkg_jar-from commons-logging
	java-pkg_jar-from cglib-2
	java-pkg_jar-from jakarta-oro-2.0 jakarta-oro.jar oro.jar
	java-pkg_jar-from jakarta-regexp-1.3 jakarta-regexp.jar regexp.jar
	java-pkg_jar-from jta
	java-pkg_jar-from junit
	java-pkg_jar-from log4j
	java-pkg_jar-from servletapi-2.3
	java-pkg_jar-from xerces-1.3
	java-pkg_jar-from ldapsdk-4.1 ldapjdk.jar
	use postgres && java-pkg_jar-from jdbc2-postgresql-5
}

src_compile() {
	cd ${S}/src
	local antflags="jar"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "compile failed"
}

src_install() {
	java-pkg_newjar dist/${P}-xml.jar ${PN}-xml.jar
	java-pkg_newjar dist/${P}.jar ${PN}.jar

	use doc && java-pkg_dohtml -r build/doc/javadoc/*
	use source && java-pkg_dosrc src/main/*
}
