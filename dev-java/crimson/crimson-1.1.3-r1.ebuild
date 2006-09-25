# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/crimson/crimson-1.1.3.ebuild,v 1.11 2005/05/04 20:34:53 luckyduck Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Apache Crimson XML 1.0 parser"
HOMEPAGE="http://xml.apache.org/crimson/"
SRC_URI="http://xml.apache.org/dist/crimson/${P}-src.tar.gz"

LICENSE="Apache-1.1"
SLOT="1"
KEYWORDS="x86 ppc amd64"
IUSE="doc examples source"

DEPEND="|| ( =virtual/jdk-1.3* =virtual/jdk-1.4* )
	dev-java/ant-core
	source? ( app-arch/zip )"
RDEPEND=">virtual/jre-1.3"

src_compile() {
	eant jars $(use_doc docs)
}

src_install() {
	java-pkg_dojar build/${PN}.jar

	dodoc build/ChangeLog
	java-pkg_dohtml build/README.html
	if use doc; then
		java-pkg_dohtml -r build/docs
		java-pkg_dohtml -r -A class,java,xml build/examples
	fi
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r examples/* ${D}/usr/share/doc/${PF}/examples
	fi
	use source && java-pkg_dosrc src/javax src/org
}
