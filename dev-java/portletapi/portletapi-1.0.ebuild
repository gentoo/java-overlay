# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

JETSPEED_P="jetspeed-2.0-src"
DESCRIPTION="Jetspeed 2 Portlet API implementation of JSR 168"
HOMEPAGE="http://portals.apache.org/jetspeed-2/"
SRC_URI="mirror://apache/portals/jetspeed-2/sources/${JETSPEED_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.5
	source? ( app-arch/unzip )"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${JETSPEED_P}/portlet-api"

src_unpack() {
	unpack ${A}
	cp ${FILESDIR}/${P}-build.xml ${S}/build.xml
}

src_compile() {
	eant jar $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar target/${PN}.jar
	use doc && java-pkg_dohtml -r dist/docs
	use source && java-pkg_dosrc src/java/*
}
