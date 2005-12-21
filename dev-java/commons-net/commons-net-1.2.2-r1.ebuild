# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-net/commons-net-1.2.2-r1.ebuild,v 1.3 2005/07/09 16:01:24 axxo Exp $

inherit eutils java-pkg

DESCRIPTION="The purpose of the library is to provide fundamental protocol access, not higher-level abstractions."
HOMEPAGE="http://jakarta.apache.org/commons/net/"
SRC_URI="mirror://apache/jakarta/commons/net/source/${P}-src.tar.gz"
RDEPEND=">=virtual/jre-1.3
		=dev-java/jakarta-oro-2.0*"
DEPEND=">=virtual/jdk-1.3
		>=dev-java/ant-core-1.5.4
		jikes? ( dev-java/jikes )
		source? ( app-arch/zip )
		${RDEPEND}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="x86 sparc ppc amd64"
IUSE="doc jikes source"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/gentoo-1.2.diff
	#for some reason 1.2.2 claims its 1.3
	sed "s/commons-net-1.3.0-dev/commons-net-1.2.2-dev/" -i build.xml || die "died on sed"
}

src_compile() {
	local antflags="-Doro.jar=$(java-pkg_getjars jakarta-oro-2.0) jar"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "died on ant"
}

src_install() {
	java-pkg_newjar target/${P}-dev.jar ${PN}.jar

	use doc && java-pkg_dohtml -r dist/docs/
	use source && java-pkg_dosrc src/java/org
}
