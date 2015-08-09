# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit base java-pkg-2 java-ant-2

DESCRIPTION="Fast MD5 Implementation in Java"
HOMEPAGE="http://www.twmacinta.com/myjava/fast_md5.php"
SRC_URI="http://www.twmacinta.com/myjava/${P}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${PN}"

src_compile() {
	eant jar $(use_doc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dodoc ChangeLog README.txt

	use doc && java-pkg_dohtml -r dist/docs/javadoc
	use source && java-pkg_dosrc src/com
}
