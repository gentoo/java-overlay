# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-beanutils/commons-beanutils-1.7.0-r1.ebuild,v 1.4 2005/11/02 16:31:29 axxo Exp $

inherit java-pkg

DESCRIPTION="Provides easy-to-use wrappers around Reflection and Introspection APIs"
HOMEPAGE="http://jakarta.apache.org/commons/beanutils/"
SRC_URI="mirror://apache/jakarta/commons/beanutils/source/${P}-src.tar.gz"

LICENSE="Apache-1.1"
SLOT="1.7"
KEYWORDS="x86 ppc sparc amd64 ppc64"
IUSE="doc jikes source"

RDEPEND=">=virtual/jre-1.3
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-logging-1.0.2"
DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )
	${RDEPEND}"

S=${WORKDIR}/${P}-src

src_unpack() {
	unpack ${A}
	cd ${S}

	echo "commons-collections.jar=$(java-pkg_getjars commons-collections)" 	> build.properties
	echo "commons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)" >> build.properties
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "failed to compile"
}

src_install() {
	java-pkg_dojar dist/${PN}*.jar

	dodoc RELEASE-NOTES.txt
	java-pkg_dohtml STATUS.html PROPOSAL.html

	use doc && java-pkg_dohtml -r dist/docs/*
	use source && java-pkg_dosrc src/java/*
}
