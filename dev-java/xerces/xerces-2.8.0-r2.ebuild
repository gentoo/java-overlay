# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xerces/xerces-2.7.1.ebuild,v 1.5 2006/02/17 20:26:30 hansmi Exp $

inherit eutils java-pkg-2 java-ant-2 

MY_PN="Xerces-J"
DESCRIPTION="The next generation of high performance, fully compliant XML parsers in the Apache Xerces family"
HOMEPAGE="http://xml.apache.org/xerces2-j/index.html"
SRC_URI="mirror://apache/xml/${PN}-j/${MY_PN}-src.${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc examples noxmlapis source"

RDEPEND=">=virtual/jre-1.4
	>=dev-java/ant-core-1.5.2
	=dev-java/xml-commons-external-1.3*
	>=dev-java/xml-commons-resolver-1.1
	>=dev-java/xjavac-20041208"
DEPEND=">=virtual/jdk-1.4
	source? ( app-arch/zip )
	${RDEPEND}"

S="${WORKDIR}/${PN}-${PV//./_}"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.patch
	epatch ${FILESDIR}/${P}-no_dom3.patch

	mkdir tools && cd tools
	java-pkg_jar-from xml-commons-external-1.3 xml-apis.jar
	java-pkg_jar-from xml-commons-resolver xml-commons-resolver.jar resolver.jar

	mkdir bin && cd bin
	java-pkg_jar-from --build-only xjavac-1
}

src_compile() {
    # known bug - javadocs use custom taglets, which come as bundled jar in xerces-J-tools.2.8.0.tar.gz
    # ommiting them causes non-fatal errors in javadocs generation
    # need to either find the taglets source, use the bundled jars as it's only compile-time or remove the taglet defs from build.xml
	eant jar $(use_doc javadocs) || die "Compile failed."
}

src_install() {
    # do not build/install xercesSamples.jar wrt bug #131141
	java-pkg_dojar build/xercesImpl.jar

    # attempt to fix bug #82561 - instead of own copy of xml-apis.jar install only a symlink, so upgrades of xml-commons-external get in effect
    # developers should USE noxmlapis to omit xml-apis.jar completely and fix any package they find depending on it  
    if use !noxmlapis ; then
        # dojar will make symlink to original file since this is symlink
        java-pkg_dojar tools/xml-apis.jar
        # but won't put it in classpath itself (maybe it should?), so we do it manually
        java-pkg_regjar "${D}/usr/share/${PN}-${SLOT}/lib/xml-apis.jar"
    fi

	dodoc TODO STATUS README ISSUES
	java-pkg_dohtml Readme.html
	use doc && java-pkg_dohtml -r build/docs/javadocs

	if use examples; then
		dodir "/usr/share/doc/${PF}/examples"
		cp -r samples/* "${D}/usr/share/doc/${PF}/examples"
	fi

	use source && java-pkg_dosrc "${S}/src/org"
}
