# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/saxon/saxon-8.4b-r1.ebuild,v 1.2 2006/07/22 21:34:41 nelchael Exp $

inherit versionator java-pkg-2 eutils java-ant-2

DESCRIPTION="The SAXON package is a collection of tools for processing XML documents: XSLT processor, XSL library, parser."
MY_PV=$(replace_all_version_separators -)
SRC_URI="mirror://sourceforge/${PN}/${PN}-resources${MY_PV}.zip"
HOMEPAGE="http://saxon.sourceforge.net/"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~ppc ~x86"
IUSE="doc source"

COMMON_DEP="
	dev-java/xom
	~dev-java/jdom-1.0
	=dev-java/dom4j-1*"

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
	unpack ${A}

	cp ${FILESDIR}/build-8.8.xml build.xml || die

	mkdir src
	cd src
	unpack ./../source.zip
	#Nuking the .NET stuff until I have the time to make it work
	rm -r net/sf/saxon/dotnet || die

	#epatch ${FILESDIR}/${PN}-8.4b-jikes.patch

	cd "${S}"
	#rm -v lib/*.jar
	mkdir lib && cd lib
	java-pkg_jarfrom jdom-1.0
	java-pkg_jarfrom xom
	java-pkg_jarfrom dom4j-1
}

src_install() {
	java-pkg_dojar dist/*.jar

	if use doc; then
		java-pkg_dohtml -r doc/*
		java-pkg_dojavadoc dist/doc/api
	fi

	use source && java-pkg_dosrc src/net
}
