# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/velocity/velocity-1.4-r2.ebuild,v 1.2 2005/07/09 16:12:20 swegener Exp $

inherit java-pkg eutils

DESCRIPTION="A Java-based template engine that allows easy creation/rendering of documents that format and present data."
HOMEPAGE="http://jakarta.apache.org/velocity/"
SRC_URI="mirror://apache/jakarta/velocity/binaries/${P}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~x86"
IUSE="doc j2ee jikes junit"

DEPEND=">=virtual/jdk-1.3.1
	dev-java/ant
	dev-java/antlr
	dev-java/junit
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jdk-1.3.1
	dev-java/bcel
	dev-java/commons-collections
	=dev-java/jdom-1.0_beta9*
	dev-java/log4j
	=dev-java/avalon-logkit-1.2*
	=dev-java/jakarta-oro-2.0*
	j2ee? ( =dev-java/jboss-module-j2ee-4.0* )
	=dev-java/servletapi-2.2*
	dev-java/werken-xpath"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/${P}-versioned_jar.patch

	cd ${S}/build/lib
	java-pkg_jar-from antlr
	java-pkg_jar-from bcel
	java-pkg_jar-from commons-collections
	java-pkg_jar-from jakarta-oro-2.0
	java-pkg_jar-from jdom-1.0_beta9
	java-pkg_jar-from log4j
	java-pkg_jar-from avalon-logkit-1.2
	java-pkg_jar-from servletapi-2.2
	java-pkg_jar-from werken-xpath
	use j2ee && java-pkg_jar-from jboss-module-j2ee-4
}

src_compile () {
	cd ${S}/build
	local antflags="jar jar-core jar-util jar-servlet"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadocs"
	use j2ee && antflags="${antflags} jar-J2EE"

	ant ${antflags} || die "Ant failed"
}


src_install () {
	java-pkg_dojar bin/*.jar

	dodoc NOTICE README.txt
	use doc && java-pkg_dohtml -r docs/*
}
