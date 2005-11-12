# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base java-pkg

DESCRIPTION="Fast MD5 Implementation in Java"
HOMEPAGE="http://www.twmacinta.com/myjava/fast_md5.php"
SRC_URI="http://www.twmacinta.com/myjava/${P}.zip"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip
	source? (app-arch/zip)"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${PN}"

# fixes build.xml so making the jar does not depend on javadoc
PATCHES="${FILESDIR}/${P}-build.patch"

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "ant failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dodoc ChangeLog README.txt

	use doc && java-pkg_dohtml -r dist/docs/api
	use source && java-pkg_dosrc src/com
}
