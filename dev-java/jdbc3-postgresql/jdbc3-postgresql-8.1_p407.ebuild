# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jdbc3-postgresql/jdbc3-postgresql-8.1_p404-r1.ebuild,v 1.3 2006/10/27 00:02:00 caster Exp $

inherit java-ant-2 java-pkg-2

MY_PN="postgresql-jdbc"
MY_PV="${PV/_p/-}"
MY_P="${MY_PN}-${MY_PV}.src"

DESCRIPTION="JDBC Driver for PostgreSQL"
SRC_URI="http://jdbc.postgresql.org/download/${MY_P}.tar.gz"
HOMEPAGE="http://jdbc.postgresql.org/"

LICENSE="POSTGRESQL"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE="doc examples source"

DEPEND="=virtual/jdk-1.4*
	>=dev-java/ant-core-1.6
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

# Apparently this has 1.5 specific features, which will need to handled
# somehow with use flags, and may need to patch build.xml to make sure the
# right -source / -target are used
JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4*"

S="${WORKDIR}/${MY_P}"

# There are 1.5 features, which jikes doesn't like
java-pkg_filter-compiler jikes

src_compile() {
	eant jar $(use_doc publicapi)
}

src_install() {
	java-pkg_newjar jars/postgresql.jar ${PN}.jar

	use doc && java-pkg_dohtml -r ${S}/build/publicapi/*
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r ${S}/example/* ${D}/usr/share/doc/${PF}/examples
		java-pkg_dojar jars/postgresql-examples.jar
	fi
	use source && java-pkg_dosrc ${S}/org
}
