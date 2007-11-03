# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc examples source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="dnsjava is an implementation of DNS in Java."
HOMEPAGE="http://www.dnsjava.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="BSD"
SLOT="1.3.2" #used by plexus-server (maven)
KEYWORDS="~x86"
IUSE=""
RDEPEND="=virtual/jre-1.4*"
DEPEND="=virtual/jdk-1.4*"
EANT_DOC_TARGET="docs"

src_install() {
	java-pkg_newjar "${S}/${P}.jar" "${PN}.jar"
	use source && java-pkg_dosrc "${S}/org" "${S}"/*.java
	use doc && java-pkg_dojavadoc "${S}/doc"
}
