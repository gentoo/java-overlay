# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="JaxMe 2 is an open source implementation of JAXB, the specification for Java/XML binding."

HOMEPAGE="http://ws.apache.org/jaxme/index.html"
SRC_URI="mirror://apache/ws/jaxme/source/ws-${P}-src.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
DEPEND=">=virtual/jdk-1.3
	dev-java/xmldb
	>=dev-java/xerces-2.6.2-r1"
RDEPEND=">=virtual/jre-1.3"

S=${WORKDIR}/ws-${P}

src_unpack() {
	unpack ${A}
	cd ${S}
	cd prerequisites
	rm -rf *.jar
	java-pkg_jar-from xerces-2
	java-pkg_jar-from xmldb xmldb.jar xmldb-api-20021118.jar
}

src_compile() {
	ant -f buildapi.xml jar || die "failed to build api"
	ant -f buildjs.xml jar || die "failed to build js"
	ant -f buildxs.xml jar || die "failed to build xs"
	ant -f buildjm.xml compile || die "failed to build jm"
	ant -f buildpm.xml compile || die "failed to build pm"
}

src_install() {
	java-pkg_dojar dist/*.jar
}
