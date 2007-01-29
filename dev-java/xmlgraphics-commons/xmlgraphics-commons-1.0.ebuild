# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Apache XML Graphics Commons is a library that consists of several
reusable components used by Apache Batik and Apache FOP."
HOMEPAGE="http://xmlgraphics.apache.org/commons/index.html"
SRC_URI="mirror://apache/xmlgraphics/commons/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="source doc"

CDEPEND=">=dev-java/commons-io-1"
DEPEND=">=virtual/jdk-1.4
		source? ( app-arch/zip )
		dev-java/ant-core
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
		${CDEPEND}"

# TODO investigate producing .net libraries
# stratigies for non sun jdk's/jre's

src_unpack() {
	unpack ${A}

	cd ${S}/lib
	rm *.jar

	java-pkg_jarfrom commons-io-1 commons-io.jar commons-io-1.1.jar
}

EANT_BUILD_TARGET="jar-main"
EANT_DOC_TARGET="javadocs"

src_install(){
	java-pkg_dojar build/${PN}.jar
	use source && java-pkg_dosrc src
	use doc && java-pkg_dojavadoc build/javadocs

	java-pkg_verify-classes
}
