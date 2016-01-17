# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit versionator java-pkg-2 java-ant-2

DESCRIPTION="A collection of tools for processing XML documents: XSLT processor, XSL library, parser"
MY_PV=$(replace_all_version_separators -)
SRC_URI="mirror://sourceforge/${PN}/${PN}-resources${MY_PV}.zip"
HOMEPAGE="http://saxon.sourceforge.net/"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples source"

COMMON_DEP="
	dev-java/xom:0
	dev-java/jdom:1.0
	dev-java/dom4j:1
"
# Uses javax.xml.stream that is included
# starting with 1.6. Could also integrate
# support using dev-java/jsr173 I guess
RDEPEND=">=virtual/jre-1.6
	${COMMON_DEP}"

DEPEND=">=virtual/jdk-1.6
	app-arch/unzip
	dev-java/ant-core
	source? ( app-arch/zip )
	${COMMON_DEP}"

S=${WORKDIR}

src_unpack() {
	default

	mkdir src && cd src || die
	unpack ./../source.zip
}

java_prepare() {
	cp -i "${FILESDIR}/build-8.8.xml" build.xml || die

	#Nuking the .NET stuff until I have the time to make it work
	rm -r src/net/sf/saxon/dotnet || die

	mkdir lib && cd lib || die
	java-pkg_jarfrom jdom-1.0
	java-pkg_jarfrom xom
	java-pkg_jarfrom dom4j-1
}

src_install() {
	java-pkg_dojar dist/*.jar
	java-pkg_dolauncher ${PN}-transform --main net.sf.saxon.Transform

	if use doc; then
		java-pkg_dohtml -r doc/*
		java-pkg_dojavadoc dist/doc/api
	fi

	use examples && java-pkg_doexamples samples
	use source && java-pkg_dosrc src/net
}
