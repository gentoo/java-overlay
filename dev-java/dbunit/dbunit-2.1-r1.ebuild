# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/dbunit/dbunit-2.1.ebuild,v 1.5 2005/07/16 14:21:10 axxo Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="DBUnit is a JUnit extension targeted for database-driven projects that, puts your database into a known state between test runs."
HOMEPAGE="http://www.dbunit.org"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.4
	=dev-java/crimson-1*
	>=dev-db/hsqldb-1.7.2.4
	=dev-java/mockmaker-1.12.0*
	>=dev-java/mockobjects-0.09
	>=dev-java/poi-2.0"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	>=dev-java/ant-core-1.6
	source? ( app-arch/zip )"

src_unpack() {
	unpack ${A}

	cd ${S}
	cp ${FILESDIR}/${P}-build.xml build.xml

	mkdir ${S}/lib && cd ${S}/lib
	java-pkg_jar-from crimson-1
	java-pkg_jar-from hsqldb
	java-pkg_jar-from mockmaker-1.12
	java-pkg_jar-from mockobjects
	java-pkg_jar-from poi
}

src_compile() {
	eant jar $(use_doc docs)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r docs/*
	use source && java-pkg_dosrc src/java/*
}
