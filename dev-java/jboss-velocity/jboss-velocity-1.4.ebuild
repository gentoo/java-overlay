# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/velocity/velocity-1.4-r4.ebuild,v 1.3 2007/02/08 14:03:57 opfer Exp $

inherit java-pkg-2 java-ant-2 eutils

MY_PN="${PN//jboss-/}"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="A Java-based template engine that allows easy creation/rendering of documents that format and present data."
HOMEPAGE="http://jakarta.apache.org/velocity/"
SRC_URI="http://repository.jboss.com/apache-${MY_PN}/${PV}jboss/src/${MY_PN}-src.tgz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

DEPEND="
	!doc? ( >=virtual/jdk-1.4 )
	doc? ( || ( =virtual/jdk-1.4* =virtual/jdk-1.5* ) )
	dev-java/antlr
	dev-java/junit
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jdk-1.4
	dev-java/bcel
	dev-java/ant-core
	dev-java/commons-collections
	=dev-java/jdom-1.0_beta9*
	dev-java/log4j
	=dev-java/avalon-logkit-1.2*
	=dev-java/jakarta-oro-2.0*
	=dev-java/servletapi-2.2*
	dev-java/werken-xpath"

S="${WORKDIR}/${MY_P}/build"

pkg_setup() {
	if ! built_with_use dev-java/log4j javamail; then
		eerror "Velocity needs javamail specific classes built into"
		eerror "log4j. Please re-emerge log4j with the javamail use"
		eerror "flag turned on."
		die "log4j not built with the javamail use flag"
	fi
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${A}

	epatch "${FILESDIR}/${P}-versioned_jar.patch"

	find "${WORKDIR}" -iname *.jar | xargs rm -rf  || die

	java-ant_rewrite-classpath "${S}/build.xml"
}

EANT_GENTOO_CLASSPATH="antlr,bcel,commons-collections,jakarta-oro-2.0,jdom-1.0_beta9,log4j,avalon-logkit-1.2,servletapi-2.2,werken-xpath,junit,ant-core"
EANT_BUILD_TARGET="jar jar-core jar-util jar-servlet"
EANT_DOC_TARGET="javadocs"

src_install () {
	cd .. || die
	java-pkg_dojar bin/*.jar
	dodoc NOTICE README.txt || die
	#has other stuff besides api too
	use doc && java-pkg_dojavadoc docs/api
	use doc && java-pkg_dohtml docs/*html
	use source && java-pkg_dosrc src/java/*
}
