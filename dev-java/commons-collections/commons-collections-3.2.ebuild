# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-collections/commons-collections-3.1-r1.ebuild,v 1.5 2006/10/17 03:42:19 nichoj Exp $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="Jakarta-Commons Collections Component"
HOMEPAGE="http://jakarta.apache.org/commons/collections/"
SRC_URI="mirror://apache/jakarta/commons/collections/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.3"

S="${WORKDIR}/${P}-src"

src_compile() {
	eant $(use_doc) jar
}

src_install() {
	java-pkg_newjar build/${P}.jar ${PN}.jar

	dodoc README.txt
	java-pkg_dohtml *.html
	use doc && java-pkg_dohtml -r build/docs/apidocs
	use source && java-pkg_dosrc src/java/*
}
