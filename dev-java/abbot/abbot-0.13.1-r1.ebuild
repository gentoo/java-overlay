# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION=""
HOMEPAGE="http://abbot.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.jar"

LICENSE=""
SLOT="0.13"
# TODO need to get a package with com.apple.mrj... ie MRJToolkitStubs.zip
KEYWORDS="-*"
IUSE="doc" 

LDEPEND="dev-java/apple-java-extensions-bin
		~dev-java/jdom-1.0_beta10
		>=dev-java/xerces-2.7
		=dev-java/gnu-regexp-1*
		dev-java/bsh"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip
	${LDEPEND}"
RDEPEND=">=virtual/jre-1.4
	${LDEPEND}"

src_unpack() {
	mkdir -p ${S}
	cd ${S}
	unzip -qq ${DISTDIR}/${A}

	epatch ${FILESDIR}/${P}-gentoo.patch

	mkdir lib
	cd lib

	java-pkg_jar-from apple-java-extensions-bin
	java-pkg_jar-from jdom-1.0_beta10
	java-pkg_jar-from xerces-2 xml-apis.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar
	java-pkg_jar-from bsh
	java-pkg_jar-from junit
	java-pkg_jar-from gnu-regexp-1
}

src_compile() {
	eant jar $(use_doc)
}

src_install() {
	java-pkg_dojar build/${PN}.jar
	use doc && java-pkg_dohtml -r doc/api
}

# don't do tests, because they depend on a graphical environment!
src_test() {
	:;
}
