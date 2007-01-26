# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Formatting Objects Processor is a print formatter driven by XSL"
HOMEPAGE="http://xmlgraphics.apache.org/fop/"
SRC_URI="mirror://apache/xmlgraphics/${PN}/source/${P}-src.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND=">=dev-java/avalon-framework-4.2
		dev-java/commons-logging
		>=dev-java/batik-1.6
		>=dev-java/commons-io-1.1
		dev-java/xalan"

DEPEND=">=virtual/jdk-1.4
		>=dev-java/ant-core-1.6
		=dev-java/servletapi-2.4*
		app-arch/unzip
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
		${CDEPEND}"

#S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd ${S}
	cd lib
	rm *.jar

	local packages="avalon-framework-4.2 xerces-2 commons-logging commons-io-1 xalan"

	for package in `echo ${packages}`; do
		java-pkg_jarfrom ${package}	
	done

	java-pkg_jarfrom batik-1.6 batik-all.jar
	java-pkg_jarfrom servletapi-2.4 servlet-api.jar

}

src_compile() {
	export ANT_OPTS="-Xmx512M"
	eant dist
}
