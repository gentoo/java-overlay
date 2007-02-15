# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xerces/xerces-1.3.1-r2.ebuild,v 1.2 2006/10/05 17:03:13 gustavoz Exp $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

S=${WORKDIR}/xerces-${PV//./_}
DESCRIPTION="The next generation of high performance, fully compliant XML parsers in the Apache Xerces family"
HOMEPAGE="http://xml.apache.org/xerces2-j/index.html"
SRC_URI="http://archive.apache.org/dist/xml/xerces-j/Xerces-J-src.${PV}.tar.gz"

LICENSE="Apache-1.1"
SLOT="1.3"
KEYWORDS="~amd64 ~ppc ~x86"

DEPEND="
	doc? ( || ( =virtual/jdk-1.4* =virtual/jdk-1.5* ) )
	!doc? ( >=virtual/jdk-1.4 )"
RDEPEND=">=virtual/jre-1.4"

EANT_DOC_TARGET="javadocs"

src_test() {
	eant test
}

src_install() {
	java-pkg_dojar build/${PN}.jar

	dodoc README STATUS || die
	java-pkg_dohtml Readme.html || die
	use doc && java-pkg_dojavadoc ./build/docs/html/apiDocs
	use source && java-pkg_dosrc ${S}/src/{javax,org}
}
