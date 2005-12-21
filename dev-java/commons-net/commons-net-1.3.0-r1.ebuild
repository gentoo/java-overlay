# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-net/commons-net-1.3.0-r1.ebuild,v 1.5 2005/11/22 03:23:20 nichoj Exp $

inherit eutils java-pkg

DESCRIPTION="The purpose of the library is to provide fundamental protocol access, not higher-level abstractions."
HOMEPAGE="http://jakarta.apache.org/commons/net/"
SRC_URI="mirror://apache/jakarta/commons/net/source/${P}-src.tar.gz"
RDEPEND=">=virtual/jre-1.3
	>=dev-java/jakarta-oro-2.0"
DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.5.4
	junit? ( dev-java/junit )
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )
	${RDEPEND}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~sparc ~ppc ~amd64 ppc64"
IUSE="doc examples jikes junit source"

S=${WORKDIR}/${P}-src

src_unpack() {
	unpack ${A}
	cd ${S}
	mkdir -p target/lib
	cd target/lib
	java-pkg_jar-from jakarta-oro-2.0 jakarta-oro.jar oro.jar

	cd ${S}
	if ! use junit ; then
			sed -i 's/depends="compile,test"/depends="compile"/' build.xml || die "Failed to disable junit"
	else
		if ! has_version dev-java/ant-tasks; then
			sed -i 's/depends="compile,test"/depends="compile"/' build.xml || die "Failed to disable junit"
		fi
	fi
}

src_compile() {
	local antflags="jar -Dnoget=true"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "died on ant"
}

src_install() {
	java-pkg_newjar target/${P}-dev.jar ${PN}.jar

	use doc && java-pkg_dohtml -r dist/docs/
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r src/java/examples/* ${D}/usr/share/doc/${PF}/examples
	fi
	use source && java-pkg_dosrc src/java/org
}
