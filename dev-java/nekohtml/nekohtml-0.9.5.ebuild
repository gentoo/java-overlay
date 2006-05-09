# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="A simple HTML scanner and tag balancer using standard XML interfaces."

HOMEPAGE="http://people.apache.org/~andyc/neko/doc/html/"
SRC_URI="http://www.apache.org/~andyc/neko/${P}.tar.gz"
DEPEND=">=virtual/jdk-1.3
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.3
		=dev-java/xerces-2*
		dev-java/xalan"
LICENSE="CyberNeko Software License-1.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc"

# FIXME need patch for xerces-2.7
src_unpack() {
	unpack ${A}
	cd ${S}
#	epatch ${FILESDIR}/${PN}-0.9.4-build-html.xml.patch
	echo "xerces.jar=$(java-config -p xerces-2)" > build.properties
	echo "xalan.jar=$(java-config -p xalan)" >> build.properties
}

src_compile() {
	local antflags="-buildfile build-html.xml clean jar"
	eant ${antflags} $(use_doc doc)
}

src_install() {
	java-pkg_dojar *.jar

	dodoc README_HTML TODO_html
	use doc && java-pkg_dohtml -r doc/html
}
