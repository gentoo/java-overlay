# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://www.mongus.com/Topics/Web%20Development/Stripernate/files/${P}-source.jar"

LICENSE="apache-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"


#dependancies from browser thru the source
#hibernate and hibernate-annotations
#servlet-api
#stripes
#commons-logging
RDEPEND=">=virtual/jre-1.5
		>=dev-java/commons-logging-1.0.4	
		dev-java/stripes
		>=dev-java/hibernate-3.2
		>=dev-java/hibernate-annotations-3.2
		=dev-java/servletapi-2.4*
		dev-java/glassfish-persistence"
DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		${DEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cp ${FILESDIR}/build.xml .
	mkdir -p src
	mv com src/
	mkdir -p lib
	cd lib	
	java-pkg_jarfrom servletapi-2.4
	java-pkg_jarfrom commons-logging
	java-pkg_jarfrom stripes-1.4
	java-pkg_jarfrom hibernate-3.2
	java-pkg_jarfrom hibernate-annotations-3.2
	java-pkg_jarfrom glassfish-persistence
}

src_compile() {
	eant jar $(use_doc javadoc)
}
