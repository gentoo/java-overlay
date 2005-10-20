# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="mirror://gentoo/${P}.tar.gz"
# download http://svn.plexus.codehaus.org/tags/plexus-utils-1.0.1.tar.gz?view=tar
LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/tags/${P}"

src_unpack() {
	unpack ${A}
	cd ${S}
	cp ${FILESDIR}/build-${PVR}.xml build.xml
}

src_compile() {
	local antflags="jar -Dproject.name=${PN}"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	ant ${antflags} || die "Compile failed"
}

src_install() {
	java-pkg_dojar dist/*.jar
	use doc && java-pkg_dohtml -r dist/doc/api
}
