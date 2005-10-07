# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-io/commons-io-1.0.ebuild,v 1.3 2005/07/12 12:01:29 axxo Exp $

inherit java-pkg eutils

DESCRIPTION="Commons-IO contains utility classes  , stream implementations, file filters  , and endian classes."
HOMEPAGE="http://jakarta.apache.org/commons/io"
SRC_URI="mirror://apache/jakarta/commons/io/source/${P}-src.tar.gz"

LICENSE="Apache-1.1"
SLOT="1"
KEYWORDS="x86 amd64 ~ppc"
IUSE="doc jikes junit source"

DEPEND="dev-java/ant-core
	jikes? ( >=dev-java/jikes-1.21 )
	junit? ( >=dev-java/junit-3.8 dev-java/ant-tasks )
	source? ( app-arch/zip )
	>=virtual/jdk-1.3"
RDEPEND=">=virtual/jre-1.3"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.diff
	mkdir -p target/lib
	cd target/lib
	use junit && java-pkg_jar-from junit
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use junit && antflags="${antflags} test"
	ant ${antflags} || die "compile problem"
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar

	dohtml PROPOSAL.html STATUS.html usersguide.html
	use doc && java-pkg_dohtml -r dist/docs/*
	use source && java-pkg_dosrc src/java/*
}
