# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc source examples"

inherit eutils java-pkg-2 java-ant-2

MY_PN="Jaminid"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Jaminid is a very small daemon meant to embed in Java applications as an add-on HTTP interface."
HOMEPAGE="http://jaminid.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tgz"
LICENSE="LGPL-2" #Assuming v2
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

S="${WORKDIR}/${MY_PN}"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	mv src/com/prolixtech/jaminid_examples . -v
	epatch "${FILESDIR}"/${P}-utf8.patch
	sed -i -e 's/config\/MIME.XML/\/usr\/share\/jaminid\/config\/MIME.XML/g' src/com/prolixtech/jaminid/Protocol.java
	cp -v "${FILESDIR}"/build.xml . || die
}

src_install() {
	java-pkg_dojar ${PN}.jar
	insinto /usr/share/jaminid
	doins -r config || die "doins failed."
	use doc && java-pkg_dojavadoc docs
	use source && java-pkg_dosrc src/com
	use examples && java-pkg_doexamples jaminid_examples
	dodoc README.TXT || die
}
