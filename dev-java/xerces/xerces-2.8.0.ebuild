# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xerces/xerces-2.7.1.ebuild,v 1.5 2006/02/17 20:26:30 hansmi Exp $

inherit java-pkg eutils

MY_PN="Xerces-J"
DESCRIPTION="The next generation of high performance, fully compliant XML parsers in the Apache Xerces family"
HOMEPAGE="http://xml.apache.org/xerces2-j/index.html"
SRC_URI="mirror://apache/xml/${PN}-j/${MY_PN}-src.${PV}.tar.gz"

LICENSE="Apache-1.1"
SLOT="2"
KEYWORDS="amd64 ppc x86"
IUSE="doc jikes examples source"

RDEPEND=">=virtual/jre-1.4
	>=dev-java/ant-core-1.5.2
	=dev-java/xml-commons-external-1.3*
	>=dev-java/xml-commons-resolver-1.1
	>=dev-java/xjavac-20041208"
DEPEND=">=virtual/jdk-1.4
	jikes? ( >=dev-java/jikes-1.21 )
	source? ( app-arch/zip )
	${RDEPEND}"

S="${WORKDIR}/${PN}-${PV//./_}"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${PF}-gentoo.patch
	epatch ${FILESDIR}/${P}-no_dom3.patch

	mkdir tools && cd tools
	rm -f *.jar
	java-pkg_jar-from xml-commons-external-1.3 xml-apis.jar
	java-pkg_jar-from xml-commons-resolver xml-commons-resolver.jar resolver.jar

	mkdir ${S}/tools/bin
	cd ${S}/tools/bin
	java-pkg_jar-from xjavac-1
}

src_compile() {
	local antflags="jars"
	use doc && antflags="${antflags} javadocs"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "Compile failed."
}

src_install() {
	java-pkg_dojar build/x*.jar

	dodoc TODO STATUS README ISSUES
	java-pkg_dohtml Readme.html

	use doc && java-pkg_dohtml -r build/docs/javadocs
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r samples/* ${D}/usr/share/doc/${PF}/examples
	fi
	use source && java-pkg_dosrc ${S}/src/*
}
