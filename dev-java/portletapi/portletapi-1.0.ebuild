# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-fileupload/commons-fileupload-1.0.ebuild,v 1.18 2005/11/05 11:31:43 betelgeuse Exp $

inherit eutils java-pkg-2 java-ant-2

S="${WORKDIR}/jetspeed-2.0-src"

DESCRIPTION="Jetspeed 2 Portlet API implementation of JSR 168"
HOMEPAGE="http://portals.apache.org/jetspeed-2/"
SRC_URI="mirror://apache/portals/jetspeed-2/sources/jetspeed-2.0-src.tar.gz"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.5
	source? ( app-arch/unzip )"
RDEPEND=">=virtual/jre-1.4"
LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

src_unpack() {
	unpack ${A}
	cp ${FILESDIR}/${P}-build.xml ${S}/portlet-api/build.xml
}

src_compile() {
	cd ${S}/portlet-api
	eant jar $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar portlet-api/target/${PN}.jar
	use doc && java-pkg_dohtml -r portlet-api/dist/docs
	use source && java-pkg_dosrc portlet-api/src/java/*
}
