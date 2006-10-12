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
LICENSE="CyberNeko-1.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc"

src_unpack() {
	unpack ${A}
	cd ${S}
	# fixes compile errors due to API changes of xerces
	# TODO report upstream and fix properly instead of throwing
	# UnsupportedOperationException
	epatch ${FILESDIR}/${P}-xerces.patch
	# TODO sanify classpath for building, and submit upstream
	java-ant_rewrite-classpath build-html.xml
}

src_compile() {
	eant -f build-html.xml clean jar $(use_doc doc) \
		-Dgentoo.classpath=$(java-pkg_getjars xerces-2,xalan)
}

src_install() {
	java-pkg_dojar *.jar

	dodoc README_HTML TODO_html
	use doc && java-pkg_dohtml -r doc/html
}
