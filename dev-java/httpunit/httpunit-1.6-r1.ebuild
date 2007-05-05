# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="HttpUnit emulates the relevant portions of browser behavior."
HOMEPAGE="http://httpunit.sourceforge.net/"
# TODO what is metainf for?
# TODO where did it come from?
SRC_URI="mirror://sourceforge/${PN}/${P}.zip
	http://gentooexperimental.org/distfiles/${P}-metainf.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	dev-java/jtidy
	=dev-java/rhino-1.6*
	dev-java/nekohtml
	=dev-java/servletapi-2.3*
	>=dev-java/xerces-2.7"

TIDY="jtidy Tidy.jar"
JS="rhino-1.6 js.jar"
JUNIT="junit junit.jar"
NEKOHTML="nekohtml nekohtml.jar"
SERVLET="servletapi-2.3 servlet.jar"
XERCES_IMPL="xerces-2 xercesImpl.jar"
XML_PARSER_APIS="xerces-2 xmlParserAPIs.jar"

src_unpack() {
	unpack ${A}

	einfo "Fixing jars in jars/"
	cd ${S}/jars
	java-pkg_jar-from ${TIDY}
	java-pkg_jar-from ${JS}
	java-pkg_jar-from ${JUNIT}
	java-pkg_jar-from ${NEKOHTML}
	java-pkg_jar-from ${SERVLET}
	java-pkg_jar-from ${XERCES_IMPL}
	java-pkg_jar-from ${XML_PARSER_APIS}
}

src_compile() {
	java-pkg_filter-compiler jikes
	eant clean jar $(use_doc javadocs)
}

src_install() {
	java-pkg_dojar lib/${PN}.jar
	dodoc doc/*.txt
	if use doc; then
		java-pkg_dohtml -r doc/api doc/manual doc/tutorial
	fi
}
