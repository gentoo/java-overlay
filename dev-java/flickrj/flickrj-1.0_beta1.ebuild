# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

DESCRIPTION="Flickrj is Java API which wraps the REST-based Flickr API"
HOMEPAGE="http://flickrj.sourceforge.net/"
SRC_URI="${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc source"

CDEPEND=">=dev-java/commons-logging-1.0.4
		>=dev-java/commons-discovery-0.2
		>=www-servers/axis-1.2
		>=dev-java/log4j-1.2.8
		>=dev-java/sun-saaj-bin-1.3
		>=dev-java/sun-jaxrpc-bin-1.1.3.01"
RDEPEND=">=virtual/jre-1.5
		${CDEPEND}"
DEPEND=">=virtual/jdk-1.5
		${CDEPEND}
		dev-java/ant-core
		source? ( app-arch/zip )"

S="${WORKDIR}/${PN}"

EANT_EXTRA_ARGS="-Dvname=${PN}"
EANT_DOC_TARGET="javadocs"

src_unpack() {
	unpack ${A}

	cd ${S}/lib

	rm *.jar

	#axis.jar
	java-pkg_jarfrom commons-discovery commons-discovery.jar commons-discovery-0.2.jar
	java-pkg_jarfrom commons-logging commons-logging.jar commons-logging-1.0.4.jar
	java-pkg_jarfrom sun-jaxrpc-bin jaxrpc-api.jar jaxrpc.jar
	java-pkg_jarfrom sun-saaj-bin saaj-api.jar saaj.jar
	java-pkg_jarfrom log4j
	java-pkg_jarfrom axis-1 axis.jar
}

src_install() {
	java-pkg_dojar build/${PN}.jar
	use doc && java-pkg_dojavadoc build/docs/api
	use source && java-pkg_dosrc src
}

