# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://download.java.net/javaee5/fcs_branch/promoted/source/glassfish-9_0-b48-src.zip"

LICENSE=""
SLOT="0"
KEYWORDS="-amd64 -x86"
IUSE=""

DEPEND=">=virtual/jdk-1.5
		app-arch/unzip"
RDEPEND=">=virtual/jre-1.5"

MODULE="persistence-api" 
S="${WORKDIR}/glassfish"

src_compile() {
	
	cd ${S}/persistence-api
	eant all 
}

src_install() {
	cd ${WORKDIR}/publish/glassfish
	java-pkg_newjar lib/javaee.jar

	dodir /usr/share/${PN}/lib/schemas
	cp schemas/*.xsd ${D}/usr/share/${PN}/lib/schemas
}
